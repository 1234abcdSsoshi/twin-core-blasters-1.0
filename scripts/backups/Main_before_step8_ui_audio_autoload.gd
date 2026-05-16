extends Node2D

const AssetPaths = preload("res://scripts/AssetPaths.gd")
const AudioManagerScript = preload("res://scripts/AudioManager.gd")

# Stage controller scripts.
# These are thin wrappers for now. They call the existing Main.gd gameplay
# functions, so we can test stage separation without moving everything at once.
const StoryStageScript = preload("res://scenes/stages/StoryStage.gd")
const AstralCourtStageScript = preload("res://scenes/stages/AstralCourtStage.gd")
const RaidStageScript = preload("res://scenes/stages/RaidStage.gd")

enum GameMode { TITLE, STORY, ASTRAL_COURT, RAID }

var mode: GameMode = GameMode.TITLE

# StageRoot is added to Main.tscn.
# New stage controller nodes are instantiated under this node.
@onready var stage_root: Node2D = $StageRoot

# Current active stage controller.
# Main.gd keeps the existing gameplay functions for now, but the selected
# stage decides which update function is called.
var current_stage: StageBase = null

var screen_size := Vector2(1920, 1080)
var rng := RandomNumberGenerator.new()
var audio_manager: Node

var players: Array[Dictionary] = []
var bullets: Array[Dictionary] = []
var enemies: Array[Dictionary] = []
var items: Array[Dictionary] = []
var effects: Array[Dictionary] = []

var team_score := 0
var p1_score := 0
var p2_score := 0
var base_hp := 100
var core_shield_time := 0.0
var coop_link := 0.0
var story_wave := 1
var result_title := ""
var result_message := ""
var game_over := false

var enemy_spawn_timer := 1.2
var item_spawn_timer := 5.0
var shoot_cd_p1 := 0.0
var shoot_cd_p2 := 0.0

# Astral Court
var arena_time := 60.0
var arena_p1_hp := 100
var arena_p2_hp := 100
var p1_core := 0.0
var p2_core := 0.0
var p1_shield := 0.0
var p2_shield := 0.0
var p1_dash_cd := 0.0
var p2_dash_cd := 0.0
var p1_ult_ready := false
var p2_ult_ready := false
var arena_obstacles: Array[Rect2] = []
var astral_core_pos := Vector2.ZERO

# Raid
var raid_phase := 1
var raid_link := 0.0
var raid_attack_timer := 1.8
var raid_drone_timer := 4.0
var raid_weak_index := 1
var raid_weak_timer := 3.5
var raid_boss_hp := 700
var raid_boss_max_hp := 700
var raid_message := "Break the glowing weak core."
var raid_boss_time := 0.0
var raid_boss_center := Vector2.ZERO
var raid_weak_offsets: Array[Vector2] = [Vector2(-240, 70), Vector2(0, 92), Vector2(240, 70)]

# Visual nodes
var bg_sprite: Sprite2D
var base_sprite: Sprite2D
var base_shield_sprite: Sprite2D
var astral_ring_sprite: Sprite2D
var arena_obstacle_sprites: Array[Sprite2D] = []
var boss_sprite: Sprite2D
var raid_weak_sprites: Array[Sprite2D] = []
var fusion_sprite: Sprite2D

# UI
var ui_layer: CanvasLayer
var hud_label: Label
var title_layer: CanvasLayer
var title_label: Label
var title_options_label: Label
var game_over_layer: CanvasLayer
var game_over_title: Label
var game_over_detail: Label
var banner_label: Label
var link_back: ColorRect
var link_fill: Sprite2D
var boss_hp_back: Sprite2D
var boss_hp_fill: ColorRect

func _ready() -> void:
	rng.randomize()
	screen_size = get_viewport_rect().size
	_setup_world()
	_setup_ui()
	audio_manager = AudioManagerScript.new()
	add_child(audio_manager)
	_show_title()

func _process(delta: float) -> void:
	if game_over:
		if Input.is_key_pressed(KEY_R):
			get_tree().reload_current_scene()
		_update_ui()
		_update_effects(delta)
		return

	if mode == GameMode.TITLE:
		_handle_title_input()
		return

	shoot_cd_p1 = maxf(0.0, shoot_cd_p1 - delta)
	shoot_cd_p2 = maxf(0.0, shoot_cd_p2 - delta)

	# Common update shared by all current stages.
	# Later, these updates will move into StageBase or stage-specific files.
	_update_players(delta)
	_update_bullets(delta)
	_update_items(delta)
	_update_effects(delta)

	# Stage-specific update now goes through the active stage controller.
	# This replaces the previous match statement:
	# STORY -> _update_story(delta)
	# ASTRAL_COURT -> _update_astral_court(delta)
	# RAID -> _update_raid(delta)
	if current_stage != null:
		current_stage.update_stage(delta)

	_update_ui()

func _setup_world() -> void:
	bg_sprite = AssetPaths.create_sprite(AssetPaths.BACKGROUNDS["space"], screen_size, Color(0.02, 0.02, 0.08), -100)
	bg_sprite.position = screen_size * 0.5
	add_child(bg_sprite)

	base_sprite = AssetPaths.create_sprite(AssetPaths.STAGES["base_core"], Vector2(190, 190), Color(0.2, 0.9, 1.0), 0)
	base_sprite.position = screen_size * 0.5
	add_child(base_sprite)

	base_shield_sprite = AssetPaths.create_sprite(AssetPaths.EFFECTS["shield_bubble"], Vector2(260, 260), Color(0.5, 0.9, 1.0, 0.7), 2)
	base_shield_sprite.position = base_sprite.position
	base_shield_sprite.visible = false
	add_child(base_shield_sprite)

	astral_ring_sprite = AssetPaths.create_sprite(AssetPaths.STAGES["astral_ring"], Vector2(900, 900), Color(0.9, 0.75, 0.25, 0.4), -20)
	astral_ring_sprite.position = screen_size * 0.5
	astral_ring_sprite.visible = false
	add_child(astral_ring_sprite)

	fusion_sprite = AssetPaths.create_sprite(AssetPaths.PLAYERS["fusion"], Vector2(220, 220), Color(0.4, 1.0, 0.7), 40)
	fusion_sprite.visible = false
	add_child(fusion_sprite)

	for i in range(2):
		var obstacle := AssetPaths.create_sprite(AssetPaths.STAGES["arena_obstacle"], Vector2(180, 130), Color(0.7, 0.8, 1.0, 0.5), 2)
		obstacle.visible = false
		add_child(obstacle)
		arena_obstacle_sprites.append(obstacle)

	boss_sprite = AssetPaths.create_sprite(AssetPaths.BOSSES["crimson"], Vector2(480, 250), Color(0.8, 0.0, 0.25), 5)
	boss_sprite.visible = false
	add_child(boss_sprite)

	for i in range(3):
		var weak := AssetPaths.create_sprite(AssetPaths.BOSSES["weak_core"], Vector2(86, 86), Color(1.0, 0.0, 0.6), 15)
		weak.visible = false
		add_child(weak)
		raid_weak_sprites.append(weak)

	_create_players()

func _setup_ui() -> void:
	ui_layer = CanvasLayer.new()
	add_child(ui_layer)

	hud_label = Label.new()
	hud_label.position = Vector2(36, 28)
	hud_label.size = Vector2(820, 180)
	hud_label.add_theme_font_size_override("font_size", 30)
	hud_label.add_theme_color_override("font_color", Color(0.95, 0.97, 1.0))
	ui_layer.add_child(hud_label)

	banner_label = Label.new()
	banner_label.position = Vector2(0, 92)
	banner_label.size = Vector2(screen_size.x, 70)
	banner_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner_label.add_theme_font_size_override("font_size", 48)
	banner_label.add_theme_color_override("font_color", Color(1.0, 0.92, 0.22))
	ui_layer.add_child(banner_label)

	link_back = ColorRect.new()
	link_back.position = Vector2(screen_size.x * 0.5 - 330, screen_size.y - 80)
	link_back.size = Vector2(660, 26)
	link_back.color = Color(0.06, 0.08, 0.12, 0.86)
	link_back.visible = false
	ui_layer.add_child(link_back)

	link_fill = AssetPaths.create_sprite(AssetPaths.UI["link_fill"], Vector2(660, 26), Color(0.2, 1.0, 0.65), 100)
	link_fill.position = link_back.position + link_back.size * 0.5
	link_fill.visible = false
	ui_layer.add_child(link_fill)

	boss_hp_back = AssetPaths.create_sprite(AssetPaths.UI["boss_hp_back"], Vector2(700, 36), Color(0.18, 0.02, 0.05), 100)
	boss_hp_back.position = Vector2(screen_size.x * 0.5, 222)
	boss_hp_back.visible = false
	ui_layer.add_child(boss_hp_back)

	boss_hp_fill = ColorRect.new()
	boss_hp_fill.position = Vector2(screen_size.x * 0.5 - 330, 213)
	boss_hp_fill.size = Vector2(660, 18)
	boss_hp_fill.color = Color(1.0, 0.08, 0.25)
	boss_hp_fill.visible = false
	ui_layer.add_child(boss_hp_fill)

	title_layer = CanvasLayer.new()
	title_layer.layer = 20
	add_child(title_layer)

	var back := ColorRect.new()
	back.size = screen_size
	back.color = Color(0, 0, 0, 0.82)
	title_layer.add_child(back)

	title_label = Label.new()
	title_label.text = "TWIN CORE BLASTERS"
	title_label.position = Vector2(0, 210)
	title_label.size = Vector2(screen_size.x, 96)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 76)
	title_label.add_theme_color_override("font_color", Color(0.2, 1.0, 0.85))
	title_layer.add_child(title_label)

	title_options_label = Label.new()
	title_options_label.text = "1  STORY MODE      2  ASTRAL COURT      3  ECLIPSE LEVIATHAN\n\nP1: WASD + F      P2: Arrow Keys + L"
	title_options_label.position = Vector2(0, 430)
	title_options_label.size = Vector2(screen_size.x, 260)
	title_options_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_options_label.add_theme_font_size_override("font_size", 42)
	title_options_label.add_theme_color_override("font_color", Color(1, 1, 1))
	title_layer.add_child(title_options_label)

	game_over_layer = CanvasLayer.new()
	game_over_layer.layer = 30
	game_over_layer.visible = false
	add_child(game_over_layer)
	var over_back := ColorRect.new()
	over_back.position = Vector2.ZERO
	over_back.size = screen_size
	over_back.color = Color(0, 0, 0, 0.78)
	game_over_layer.add_child(over_back)
	var panel := ColorRect.new()
	panel.position = Vector2(screen_size.x * 0.5 - 430, screen_size.y * 0.5 - 190)
	panel.size = Vector2(860, 380)
	panel.color = Color(0.03, 0.06, 0.12, 0.92)
	game_over_layer.add_child(panel)
	game_over_title = Label.new()
	game_over_title.position = Vector2(0, screen_size.y * 0.5 - 145)
	game_over_title.size = Vector2(screen_size.x, 80)
	game_over_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	game_over_title.add_theme_font_size_override("font_size", 62)
	game_over_title.add_theme_color_override("font_color", Color(1.0, 0.92, 0.24))
	game_over_layer.add_child(game_over_title)
	game_over_detail = Label.new()
	game_over_detail.position = Vector2(0, screen_size.y * 0.5 - 42)
	game_over_detail.size = Vector2(screen_size.x, 170)
	game_over_detail.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	game_over_detail.add_theme_font_size_override("font_size", 32)
	game_over_detail.add_theme_color_override("font_color", Color(0.92, 0.96, 1.0))
	game_over_layer.add_child(game_over_detail)

func _show_title() -> void:
	mode = GameMode.TITLE
	title_layer.visible = true
	banner_label.text = ""
	if audio_manager != null:
		audio_manager.play_bgm("home")

func _handle_title_input() -> void:
	# The title menu now loads a stage controller instead of directly starting
	# each mode. This is the first step toward splitting Main.gd.
	if Input.is_key_pressed(KEY_1) or Input.is_key_pressed(KEY_ENTER) or Input.is_key_pressed(KEY_SPACE):
		_load_stage(StoryStageScript)
	elif Input.is_key_pressed(KEY_2):
		_load_stage(AstralCourtStageScript)
	elif Input.is_key_pressed(KEY_3):
		_load_stage(RaidStageScript)

func _load_stage(stage_script: Script) -> void:
	# Remove the previous stage controller if one exists.
	# This does not remove the visual game objects yet; the existing _start_*()
	# functions still call _clear_game_objects() as before.
	if current_stage != null:
		current_stage.queue_free()
		current_stage = null

	# Create a new stage controller node and attach the selected stage script.
	var stage_node := Node2D.new()
	stage_node.set_script(stage_script)
	stage_root.add_child(stage_node)

	current_stage = stage_node as StageBase
	if current_stage == null:
		push_error("Failed to load stage controller.")
		return

	# Connect the common stage-finished signal.
	# We will use this more when result screens are moved out of Main.gd.
	current_stage.stage_finished.connect(_on_stage_finished)

	# Give the stage a reference to Main.gd for this transition step.
	current_stage.setup_stage(self)
	current_stage.start_stage()

func _on_stage_finished(result: Dictionary) -> void:
	# Temporary debug hook.
	# Later this will show ResultScreen.tscn or return to the title menu.
	print("Stage finished: ", result)

func _create_players() -> void:
	players.clear()
	var p1: Dictionary = _create_player(1, AssetPaths.PLAYERS["p1"], Vector2(screen_size.x * 0.35, screen_size.y - 160), Color(0.2, 0.85, 1.0))
	var p2: Dictionary = _create_player(2, AssetPaths.PLAYERS["p2"], Vector2(screen_size.x * 0.65, screen_size.y - 160), Color(1.0, 0.66, 0.18))
	players.append(p1)
	players.append(p2)

func _create_player(id: int, path: String, pos: Vector2, color: Color) -> Dictionary:
	var sprite := AssetPaths.create_sprite(path, Vector2(95, 95), color, 10)
	sprite.position = pos
	add_child(sprite)
	var shield := AssetPaths.create_sprite(AssetPaths.EFFECTS["shield_bubble"], Vector2(150, 150), Color(0.5, 0.9, 1.0, 0.5), 11)
	shield.visible = false
	add_child(shield)
	return {
		"id": id,
		"sprite": sprite,
		"shield_sprite": shield,
		"pos": pos,
		"hp": 100,
		"speed": 440.0,
		"radius": 42.0,
		"rapid": 0.0,
	}

func _start_story() -> void:
	mode = GameMode.STORY
	title_layer.visible = false
	game_over = false
	team_score = 0
	p1_score = 0
	p2_score = 0
	base_hp = 100
	core_shield_time = 0.0
	coop_link = 0.0
	story_wave = 1
	result_title = ""
	result_message = ""
	game_over_layer.visible = false
	_clear_game_objects()
	_set_background(AssetPaths.BACKGROUNDS["space"])
	base_sprite.visible = true
	astral_ring_sprite.visible = false
	boss_sprite.visible = false
	boss_hp_back.visible = false
	boss_hp_fill.visible = false
	link_back.visible = false
	link_fill.visible = false
	for p in players:
		p["pos"] = Vector2(screen_size.x * (0.35 if p["id"] == 1 else 0.65), screen_size.y - 160)
		p["hp"] = 100
		p["rapid"] = 0.0
	banner_label.text = "STORY MODE"
	if audio_manager != null:
		audio_manager.play_bgm("story")
		audio_manager.play_sfx("stage_start")
		audio_manager.stop_shield_loop()

func _start_astral_court() -> void:
	mode = GameMode.ASTRAL_COURT
	title_layer.visible = false
	game_over = false
	game_over_layer.visible = false
	_clear_game_objects()
	_set_background(AssetPaths.BACKGROUNDS["astral"])
	base_sprite.visible = false
	base_shield_sprite.visible = false
	astral_ring_sprite.visible = true
	boss_sprite.visible = false
	boss_hp_back.visible = false
	boss_hp_fill.visible = false
	arena_time = 60.0
	arena_p1_hp = 100
	arena_p2_hp = 100
	p1_core = 0.0
	p2_core = 0.0
	p1_ult_ready = false
	p2_ult_ready = false
	astral_core_pos = screen_size * 0.5
	arena_obstacles = [
		Rect2(Vector2(screen_size.x * 0.5 - 260, screen_size.y * 0.5 - 80), Vector2(150, 120)),
		Rect2(Vector2(screen_size.x * 0.5 + 110, screen_size.y * 0.5 - 80), Vector2(150, 120)),
	]
	for i in range(arena_obstacle_sprites.size()):
		arena_obstacle_sprites[i].visible = true
		arena_obstacle_sprites[i].position = arena_obstacles[i].get_center()
	players[0]["pos"] = Vector2(220, screen_size.y * 0.5)
	players[1]["pos"] = Vector2(screen_size.x - 220, screen_size.y * 0.5)
	banner_label.text = "ASTRAL COURT"
	if audio_manager != null:
		audio_manager.play_bgm("astral")
		audio_manager.play_sfx("stage_start")
		audio_manager.stop_shield_loop()

func _start_raid() -> void:
	mode = GameMode.RAID
	title_layer.visible = false
	game_over = false
	game_over_layer.visible = false
	_clear_game_objects()
	_set_background(AssetPaths.BACKGROUNDS["raid"])
	base_sprite.visible = false
	base_shield_sprite.visible = false
	astral_ring_sprite.visible = false
	for s in arena_obstacle_sprites:
		s.visible = false
	boss_sprite.texture = AssetPaths.load_texture(AssetPaths.BOSSES["leviathan"], Color(0.45, 0.0, 0.6))
	AssetPaths.fit_sprite(boss_sprite, Vector2(560, 320))
	raid_boss_time = 0.0
	raid_boss_center = Vector2(screen_size.x * 0.5, 230)
	boss_sprite.position = raid_boss_center
	boss_sprite.visible = true
	raid_boss_hp = raid_boss_max_hp
	raid_phase = 1
	raid_link = 0.0
	raid_attack_timer = 1.6
	raid_drone_timer = 3.4
	raid_weak_index = 1
	players[0]["pos"] = Vector2(screen_size.x * 0.35, screen_size.y - 150)
	players[1]["pos"] = Vector2(screen_size.x * 0.65, screen_size.y - 150)
	boss_hp_back.visible = true
	boss_hp_fill.visible = true
	link_back.visible = true
	link_fill.visible = true
	banner_label.text = "ECLIPSE LEVIATHAN"
	if audio_manager != null:
		audio_manager.play_bgm("eclipse")
		audio_manager.play_sfx("stage_start")
		audio_manager.stop_shield_loop()

func _set_background(path: String) -> void:
	bg_sprite.texture = AssetPaths.load_texture(path, Color(0.02, 0.02, 0.08))
	AssetPaths.fit_sprite(bg_sprite, screen_size)
	bg_sprite.position = screen_size * 0.5

func _clear_game_objects() -> void:
	for arr in [bullets, enemies, items, effects]:
		for obj in arr:
			if obj.has("sprite") and is_instance_valid(obj["sprite"]):
				obj["sprite"].queue_free()
		arr.clear()
	for weak in raid_weak_sprites:
		weak.visible = false
	for s in arena_obstacle_sprites:
		s.visible = false
	fusion_sprite.visible = false

func _update_players(delta: float) -> void:
	for p in players:
		var dir := Vector2.ZERO
		var player_id: int = int(p["id"])
		var rapid: float = float(p["rapid"])
		if player_id == 1:
			dir = _input_dir(KEY_W, KEY_S, KEY_A, KEY_D)
			if Input.is_key_pressed(KEY_F) and shoot_cd_p1 <= 0.0:
				_shoot(1)
				shoot_cd_p1 = 0.14 if rapid > 0.0 else 0.26
		else:
			dir = _input_dir(KEY_UP, KEY_DOWN, KEY_LEFT, KEY_RIGHT)
			if Input.is_key_pressed(KEY_L) and shoot_cd_p2 <= 0.0:
				_shoot(2)
				shoot_cd_p2 = 0.14 if rapid > 0.0 else 0.26

		var pos: Vector2 = p["pos"]
		pos += dir * float(p["speed"]) * delta
		pos.x = clampf(pos.x, 60.0, screen_size.x - 60.0)
		pos.y = clampf(pos.y, 120.0, screen_size.y - 60.0)
		p["pos"] = pos
		p["rapid"] = maxf(0.0, rapid - delta)
		(p["sprite"] as Sprite2D).position = pos
		(p["shield_sprite"] as Sprite2D).position = pos
		(p["shield_sprite"] as Sprite2D).visible = false

	if mode == GameMode.ASTRAL_COURT:
		_handle_arena_abilities(delta)

func _input_dir(up: Key, down: Key, left: Key, right: Key) -> Vector2:
	var d := Vector2.ZERO
	if Input.is_key_pressed(up): d.y -= 1.0
	if Input.is_key_pressed(down): d.y += 1.0
	if Input.is_key_pressed(left): d.x -= 1.0
	if Input.is_key_pressed(right): d.x += 1.0
	return d.normalized() if d.length() > 0.0 else Vector2.ZERO

func _shoot(player_id: int) -> void:
	var p: Dictionary = players[player_id - 1]
	var direction := Vector2.UP
	if mode == GameMode.ASTRAL_COURT:
		direction = Vector2.RIGHT if player_id == 1 else Vector2.LEFT
	var path: String = AssetPaths.PROJECTILES["azure"] if player_id == 1 else AssetPaths.PROJECTILES["solar"]
	var origin: Vector2 = p["pos"]
	var bullet: Dictionary = _create_bullet(origin + direction * 52.0, direction, player_id, 14, path, 820.0, 36.0)
	bullets.append(bullet)
	if audio_manager != null:
		audio_manager.play_sfx("shot_azure" if player_id == 1 else "shot_solar", -8.0)

func _create_bullet(pos: Vector2, dir: Vector2, owner_id: int, damage: int, path: String, speed: float, size: float) -> Dictionary:
	var sprite := AssetPaths.create_sprite(path, Vector2(size, size), Color.WHITE, 20)
	sprite.position = pos
	sprite.rotation = dir.angle()
	add_child(sprite)
	return {"pos": pos, "vel": dir.normalized() * speed, "owner": owner_id, "damage": damage, "sprite": sprite, "radius": size * 0.5, "life": 3.2}

func _update_bullets(delta: float) -> void:
	for i in range(bullets.size() - 1, -1, -1):
		var b: Dictionary = bullets[i]
		var pos: Vector2 = b["pos"]
		var vel: Vector2 = b["vel"]
		var life: float = float(b["life"])
		pos += vel * delta
		life -= delta
		b["pos"] = pos
		b["life"] = life
		(b["sprite"] as Sprite2D).position = pos
		(b["sprite"] as Sprite2D).rotation = vel.angle()
		if life <= 0.0 or pos.x < -80 or pos.x > screen_size.x + 80 or pos.y < -80 or pos.y > screen_size.y + 80:
			_remove_bullet(i)
			continue
		_check_bullet_hits(i)

func _check_bullet_hits(index: int) -> void:
	if index < 0 or index >= bullets.size():
		return
	var b: Dictionary = bullets[index]
	var pos: Vector2 = b["pos"]
	var owner_id: int = int(b["owner"])
	var radius: float = float(b["radius"])
	if mode == GameMode.ASTRAL_COURT:
		if owner_id == 1 or owner_id == 2:
			var target: Dictionary = players[1] if owner_id == 1 else players[0]
			var target_pos: Vector2 = target["pos"]
			if pos.distance_to(target_pos) < radius + float(target["radius"]):
				if (owner_id == 1 and p2_shield > 0.0) or (owner_id == 2 and p1_shield > 0.0):
					_remove_bullet(index)
					return
				if owner_id == 1:
					arena_p2_hp = max(0, arena_p2_hp - int(b["damage"]))
					p1_score += 5
				else:
					arena_p1_hp = max(0, arena_p1_hp - int(b["damage"]))
					p2_score += 5
				_spawn_effect(AssetPaths.EFFECTS["hit_spark"], target_pos, Vector2(90, 90), 0.18)
				_remove_bullet(index)
				return
	elif mode == GameMode.RAID:
		if owner_id == 1 or owner_id == 2:
			var weak_pos := _raid_weak_pos(raid_weak_index)
			if pos.distance_to(weak_pos) < radius + 46.0:
				raid_boss_hp = max(0, raid_boss_hp - int(b["damage"]) * 5)
				raid_link = clampf(raid_link + 5.0, 0.0, 100.0)
				team_score += 12
				_spawn_effect(AssetPaths.EFFECTS["hit_spark"], weak_pos, Vector2(110, 110), 0.22)
				_remove_bullet(index)
				return
		elif owner_id == 9:
			for p in players:
				var player_pos: Vector2 = p["pos"]
				if pos.distance_to(player_pos) < radius + float(p["radius"]):
					base_hp = max(0, base_hp - int(b["damage"]))
					_spawn_effect(AssetPaths.EFFECTS["hit_spark"], player_pos, Vector2(90, 90), 0.18)
					if audio_manager != null:
						audio_manager.play_sfx("core_damage", -6.0)
					_remove_bullet(index)
					return
	else:
		if owner_id == 1 or owner_id == 2:
			for e in enemies:
				var enemy_pos: Vector2 = e["pos"]
				if pos.distance_to(enemy_pos) < radius + float(e["radius"]):
					e["hp"] = int(e["hp"]) - int(b["damage"])
					_spawn_effect(AssetPaths.EFFECTS["hit_spark"], enemy_pos, Vector2(80, 80), 0.16)
					if audio_manager != null:
						audio_manager.play_sfx("hit_small", -8.0)
					_remove_bullet(index)
					return

func _remove_bullet(index: int) -> void:
	if index < 0 or index >= bullets.size():
		return
	var b: Dictionary = bullets[index]
	if is_instance_valid(b["sprite"]):
		(b["sprite"] as Sprite2D).queue_free()
	bullets.remove_at(index)

func _update_story(delta: float) -> void:
	enemy_spawn_timer -= delta
	item_spawn_timer -= delta
	core_shield_time = maxf(0.0, core_shield_time - delta)
	base_shield_sprite.visible = core_shield_time > 0.0
	base_shield_sprite.position = base_sprite.position
	if audio_manager != null:
		if core_shield_time > 0.0:
			audio_manager.start_shield_loop()
		else:
			audio_manager.stop_shield_loop()

	var p1_pos: Vector2 = players[0]["pos"] as Vector2
	var p2_pos: Vector2 = players[1]["pos"] as Vector2
	var near_players := p1_pos.distance_to(p2_pos) < 360.0
	var near_core := p1_pos.distance_to(base_sprite.position) < 430.0 and p2_pos.distance_to(base_sprite.position) < 430.0
	if near_players or near_core:
		coop_link = clampf(coop_link + 11.0 * delta, 0.0, 100.0)
	else:
		coop_link = clampf(coop_link - 5.0 * delta, 0.0, 100.0)
	if coop_link >= 100.0 and (Input.is_key_pressed(KEY_G) or Input.is_key_pressed(KEY_K) or Input.is_key_pressed(KEY_SPACE)):
		_story_twin_core_cannon()

	if enemy_spawn_timer <= 0.0:
		_spawn_enemy()
		enemy_spawn_timer = rng.randf_range(0.65, 1.15)
	if item_spawn_timer <= 0.0:
		_spawn_item()
		item_spawn_timer = rng.randf_range(5.0, 8.0)
	_update_enemies(delta)
	if base_hp <= 0:
		_game_over("CORE DESTROYED", "The central core collapsed.\nTeam Score: %d\nPress R to return to Home" % team_score)

func _story_twin_core_cannon() -> void:
	coop_link = 0.0
	if audio_manager != null:
		audio_manager.play_sfx("twin_core_cannon", -3.0)
	fusion_sprite.position = ((players[0]["pos"] as Vector2) + (players[1]["pos"] as Vector2)) * 0.5
	fusion_sprite.visible = true
	_spawn_effect(AssetPaths.EFFECTS["twin_core_cannon"], screen_size * 0.5, Vector2(760, 280), 0.65)
	for i in range(enemies.size() - 1, -1, -1):
		var e: Dictionary = enemies[i]
		if is_instance_valid(e["sprite"]):
			(e["sprite"] as Sprite2D).queue_free()
		enemies.remove_at(i)
	team_score += 180

func _spawn_enemy() -> void:
	var roll := rng.randi_range(0, 3)
	var key: String = ["scout", "attacker", "tank", "elite"][roll]
	var hp: int = [18, 34, 70, 110][roll]
	var speed: float = [210.0, 150.0, 90.0, 125.0][roll]
	var pos := Vector2(rng.randf_range(80.0, screen_size.x - 80.0), -80.0)
	var sprite := AssetPaths.create_sprite(AssetPaths.ENEMIES[key], Vector2(90, 90), Color(0.9, 0.1, 0.2), 8)
	sprite.position = pos
	add_child(sprite)
	enemies.append({"pos": pos, "hp": hp, "speed": speed, "sprite": sprite, "radius": 44.0, "kind": key})

func _update_enemies(delta: float) -> void:
	for i in range(enemies.size() - 1, -1, -1):
		var e: Dictionary = enemies[i]
		var target: Vector2 = base_sprite.position
		if mode != GameMode.STORY and players.size() > 0:
			target = players[i % players.size()]["pos"]
		var pos: Vector2 = e["pos"]
		var dir := (target - pos).normalized()
		pos += dir * float(e["speed"]) * delta
		e["pos"] = pos
		(e["sprite"] as Sprite2D).position = pos
		if int(e["hp"]) <= 0:
			team_score += 20
			_spawn_effect(AssetPaths.EFFECTS["explosion_small"], pos, Vector2(120, 120), 0.35)
			if audio_manager != null:
				audio_manager.play_sfx("explosion_small", -7.0)
			if is_instance_valid(e["sprite"]):
				(e["sprite"] as Sprite2D).queue_free()
			enemies.remove_at(i)
		elif pos.y > screen_size.y + 100 or pos.distance_to(target) < 60.0:
			if mode == GameMode.STORY and core_shield_time > 0.0:
				core_shield_time = maxf(0.0, core_shield_time - 1.0)
				_spawn_effect(AssetPaths.EFFECTS["shield_bubble"], base_sprite.position, Vector2(290, 290), 0.28)
				if audio_manager != null:
					audio_manager.play_sfx("shield_hit", -6.0)
			else:
				base_hp = max(0, base_hp - 8)
				if audio_manager != null:
					audio_manager.play_sfx("core_damage", -7.0)
			if is_instance_valid(e["sprite"]):
				(e["sprite"] as Sprite2D).queue_free()
			enemies.remove_at(i)

func _spawn_item() -> void:
	var keys: Array[String] = ["heal", "rapid_fire", "shield", "power_boost", "link_charge"]
	var key: String = keys[rng.randi_range(0, keys.size() - 1)]
	var pos := Vector2(rng.randf_range(120.0, screen_size.x - 120.0), rng.randf_range(160.0, screen_size.y - 180.0))
	var sprite := AssetPaths.create_sprite(AssetPaths.ITEMS[key], Vector2(76, 76), Color(0.2, 1.0, 0.7), 12)
	sprite.position = pos
	add_child(sprite)
	items.append({"key": key, "pos": pos, "sprite": sprite, "radius": 42.0})

func _update_items(_delta: float) -> void:
	for i in range(items.size() - 1, -1, -1):
		var item: Dictionary = items[i]
		var item_pos: Vector2 = item["pos"]
		for p in players:
			var player_pos: Vector2 = p["pos"]
			if item_pos.distance_to(player_pos) < float(item["radius"]) + float(p["radius"]):
				_apply_item(String(item["key"]), p)
				if is_instance_valid(item["sprite"]):
					(item["sprite"] as Sprite2D).queue_free()
				items.remove_at(i)
				return

func _apply_item(key: String, p: Dictionary) -> void:
	if audio_manager != null:
		audio_manager.play_sfx("item_pickup", -5.0)
	match key:
		"heal":
			base_hp = min(100, base_hp + 20)
			if audio_manager != null:
				audio_manager.play_sfx("item_heal", -5.0)
		"rapid_fire":
			p["rapid"] = 6.0
			if audio_manager != null:
				audio_manager.play_sfx("item_rapid_fire", -5.0)
		"shield":
			core_shield_time = 7.0
			_spawn_effect(AssetPaths.EFFECTS["shield_bubble"], base_sprite.position, Vector2(300, 300), 0.55)
			if audio_manager != null:
				audio_manager.play_sfx("item_shield", -5.0)
				audio_manager.play_sfx("shield_activate", -5.0)
				audio_manager.start_shield_loop()
		"power_boost":
			team_score += 50
			if audio_manager != null:
				audio_manager.play_sfx("item_power_boost", -5.0)
		"link_charge":
			raid_link = clampf(raid_link + 20.0, 0.0, 100.0)
			if audio_manager != null:
				audio_manager.play_sfx("item_link_charge", -5.0)

func _handle_arena_abilities(delta: float) -> void:
	arena_time -= delta
	p1_shield = maxf(0.0, p1_shield - delta)
	p2_shield = maxf(0.0, p2_shield - delta)
	p1_dash_cd = maxf(0.0, p1_dash_cd - delta)
	p2_dash_cd = maxf(0.0, p2_dash_cd - delta)
	var p1_near := (players[0]["pos"] as Vector2).distance_to(astral_core_pos) < 180.0
	var p2_near := (players[1]["pos"] as Vector2).distance_to(astral_core_pos) < 180.0
	if p1_near: p1_core = clampf(p1_core + 16.0 * delta, 0.0, 100.0)
	if p2_near: p2_core = clampf(p2_core + 16.0 * delta, 0.0, 100.0)
	p1_ult_ready = p1_core >= 100.0
	p2_ult_ready = p2_core >= 100.0
	if Input.is_key_pressed(KEY_Q) and p1_dash_cd <= 0.0:
		_dash_player(0, Vector2.RIGHT)
		p1_dash_cd = 2.4
		if audio_manager != null:
			audio_manager.play_sfx("dash", -6.0)
	if Input.is_key_pressed(KEY_O) and p2_dash_cd <= 0.0:
		_dash_player(1, Vector2.LEFT)
		p2_dash_cd = 2.4
		if audio_manager != null:
			audio_manager.play_sfx("dash", -6.0)
	if Input.is_key_pressed(KEY_E): p1_shield = maxf(p1_shield, 0.8)
	if Input.is_key_pressed(KEY_P): p2_shield = maxf(p2_shield, 0.8)
	if Input.is_key_pressed(KEY_G) and p1_ult_ready:
		arena_p2_hp = max(0, arena_p2_hp - 30)
		p1_core = 0.0
		_spawn_effect(AssetPaths.EFFECTS["energy_tornado"], (players[1]["pos"] as Vector2), Vector2(190, 190), 0.55)
		if audio_manager != null:
			audio_manager.play_sfx("blue_nova", -5.0)
	if Input.is_key_pressed(KEY_K) and p2_ult_ready:
		arena_p1_hp = max(0, arena_p1_hp - 30)
		p2_core = 0.0
		_spawn_effect(AssetPaths.EFFECTS["energy_tornado"], (players[0]["pos"] as Vector2), Vector2(190, 190), 0.55)
		if audio_manager != null:
			audio_manager.play_sfx("golden_lance", -5.0)
	if arena_time <= 0.0 or arena_p1_hp <= 0 or arena_p2_hp <= 0:
		_finish_arena()

func _dash_player(index: int, dir: Vector2) -> void:
	var p: Dictionary = players[index]
	var pos: Vector2 = p["pos"]
	pos += dir * 180.0
	p["pos"] = pos
	_spawn_effect(AssetPaths.EFFECTS["dash_trail"], pos, Vector2(160, 90), 0.25)

func _finish_arena() -> void:
	var title := "DRAW"
	if arena_p1_hp > arena_p2_hp:
		title = "P1 WINS"
	elif arena_p2_hp > arena_p1_hp:
		title = "P2 WINS"
	_game_over(title, "P1 HP: %d   P2 HP: %d\nP1 Score: %d   P2 Score: %d\nPress R to return to Home" % [arena_p1_hp, arena_p2_hp, p1_score, p2_score])

func _update_astral_court(_delta: float) -> void:
	pass

func _update_raid(delta: float) -> void:
	raid_boss_time += delta
	_update_raid_boss_motion()
	if raid_boss_hp <= 0:
		_finish_raid(true)
		return
	if raid_boss_hp < raid_boss_max_hp * 0.33:
		raid_phase = 3
	elif raid_boss_hp < raid_boss_max_hp * 0.66:
		raid_phase = 2
	else:
		raid_phase = 1
	raid_attack_timer -= delta
	raid_drone_timer -= delta
	raid_weak_timer -= delta
	if raid_weak_timer <= 0.0:
		raid_weak_index = (raid_weak_index + 1) % 3
		raid_weak_timer = 3.2
	if raid_attack_timer <= 0.0:
		_spawn_raid_barrage()
		raid_attack_timer = maxf(0.65, 2.2 - raid_phase * 0.32)
	if raid_drone_timer <= 0.0:
		_spawn_raid_drone()
		raid_drone_timer = maxf(2.0, 5.2 - raid_phase * 0.7)
	var dist := (players[0]["pos"] as Vector2).distance_to(players[1]["pos"] as Vector2)
	if dist < 350.0:
		raid_link = clampf(raid_link + 10.0 * delta, 0.0, 100.0)
	else:
		raid_link = clampf(raid_link - 4.0 * delta, 0.0, 100.0)
	if raid_link >= 100.0 and (Input.is_key_pressed(KEY_G) or Input.is_key_pressed(KEY_K)):
		if audio_manager != null:
			audio_manager.play_sfx("twin_core_cannon", -3.0)
		raid_boss_hp = max(0, raid_boss_hp - 120)
		raid_link = 0.0
		_spawn_effect(AssetPaths.EFFECTS["twin_core_cannon"], Vector2(screen_size.x * 0.5, screen_size.y * 0.5), Vector2(720, 260), 0.55)
		fusion_sprite.position = ((players[0]["pos"] as Vector2) + (players[1]["pos"] as Vector2)) * 0.5
		fusion_sprite.visible = true
		team_score += 150
	_update_enemies(delta)
	_update_raid_visuals()

func _update_raid_boss_motion() -> void:
	var amp_x := 190.0 + float(raid_phase) * 70.0
	var amp_y := 24.0 + float(raid_phase) * 22.0
	var speed := 0.72 + float(raid_phase) * 0.20
	var wobble := sin(raid_boss_time * 2.2) * (18.0 if raid_phase >= 3 else 0.0)
	boss_sprite.position = raid_boss_center + Vector2(sin(raid_boss_time * speed) * amp_x, cos(raid_boss_time * speed * 1.4) * amp_y + wobble)
	boss_sprite.rotation = sin(raid_boss_time * 1.15) * (0.05 + raid_phase * 0.015)

func _spawn_raid_barrage() -> void:
	if audio_manager != null:
		audio_manager.play_sfx("shot_boss", -8.0)
	var path: String = AssetPaths.resolve_path(AssetPaths.PROJECTILES["boss_orb"], AssetPaths.PROJECTILES["boss_ord"])
	for i in range(3 + raid_phase):
		var offset := (float(i) - float(2 + raid_phase) * 0.5) * 80.0
		var start := boss_sprite.position + Vector2(offset, 80)
		var dir := Vector2(offset * 0.002, 1.0).normalized()
		bullets.append(_create_bullet(start, dir, 9, 8 + raid_phase * 2, path, 340.0 + raid_phase * 60.0, 42.0))

func _spawn_raid_drone() -> void:
	var pos := boss_sprite.position + Vector2(rng.randf_range(-300, 300), 120)
	var sprite := AssetPaths.create_sprite(AssetPaths.BOSSES["leviathan_drone"], Vector2(95, 95), Color(0.7, 0.0, 0.8), 8)
	sprite.position = pos
	add_child(sprite)
	enemies.append({"pos": pos, "hp": 45 + raid_phase * 20, "speed": 100.0 + raid_phase * 25.0, "sprite": sprite, "radius": 44.0, "kind": "leviathan_drone"})

func _raid_weak_pos(index: int) -> Vector2:
	return boss_sprite.position + raid_weak_offsets[index]

func _update_raid_visuals() -> void:
	boss_hp_fill.size = Vector2(660.0 * float(raid_boss_hp) / float(raid_boss_max_hp), 18)
	link_fill.scale.x = maxf(0.01, raid_link / 100.0)
	link_fill.visible = true
	for i in range(raid_weak_sprites.size()):
		raid_weak_sprites[i].visible = true
		raid_weak_sprites[i].position = _raid_weak_pos(i)
		raid_weak_sprites[i].modulate = Color(1, 1, 1, 1) if i == raid_weak_index else Color(0.35, 0.2, 0.45, 0.55)

func _finish_raid(victory: bool) -> void:
	if victory:
		_game_over("RAID CLEAR", "Eclipse Leviathan defeated.\nTeam Score: %d\nPress R to return to Home" % team_score)
	else:
		_game_over("RAID FAILED", "Team Hull collapsed.\nTeam Score: %d\nPress R to retry" % team_score)

func _spawn_effect(path: String, pos: Vector2, size: Vector2, duration: float) -> void:
	var sprite := AssetPaths.create_sprite(path, size, Color(1, 1, 1, 0.7), 50)
	sprite.position = pos
	add_child(sprite)
	effects.append({"sprite": sprite, "time": duration, "max_time": duration})

func _update_effects(delta: float) -> void:
	for i in range(effects.size() - 1, -1, -1):
		var e: Dictionary = effects[i]
		e["time"] = float(e["time"]) - delta
		if is_instance_valid(e["sprite"]):
			(e["sprite"] as Sprite2D).modulate.a = maxf(0.0, float(e["time"]) / float(e["max_time"]))
		if float(e["time"]) <= 0.0:
			if is_instance_valid(e["sprite"]):
				(e["sprite"] as Sprite2D).queue_free()
			effects.remove_at(i)

func _update_ui() -> void:
	match mode:
		GameMode.TITLE:
			hud_label.text = ""
			banner_label.text = ""
		GameMode.STORY:
			hud_label.text = "CO-OP DEFENSE\nCORE %d   SHIELD %.0fs   SCORE %d\nCO-OP LINK %.0f%%" % [base_hp, core_shield_time, team_score, coop_link]
			banner_label.text = "TWIN CORE CANNON READY" if coop_link >= 100.0 else "DEFEND THE CORE TOGETHER"
		GameMode.ASTRAL_COURT:
			hud_label.text = "ASTRAL COURT\nTIME %.0f   P1 HP %d   P2 HP %d\nP1 CORE %.0f%%   P2 CORE %.0f%%" % [arena_time, arena_p1_hp, arena_p2_hp, p1_core, p2_core]
			banner_label.text = "CONTROL THE STELLAR CORE"
		GameMode.RAID:
			hud_label.text = "ECLIPSE LEVIATHAN\nTEAM HULL %d   SCORE %d\nBOSS HP %d / %d   LINK %.0f%%" % [base_hp, team_score, raid_boss_hp, raid_boss_max_hp, raid_link]
			banner_label.text = "TWIN CORE CANNON READY" if raid_link >= 100.0 else "BREAK THE GLOWING CORE"

func _game_over(title: String, message: String = "") -> void:
	game_over = true
	if audio_manager != null:
		audio_manager.stop_shield_loop()
		if title.find("CLEAR") >= 0 or title.find("WINS") >= 0:
			audio_manager.play_bgm("victory")
			audio_manager.play_sfx("victory", -4.0)
		else:
			audio_manager.stop_bgm()
			audio_manager.play_sfx("game_over", -4.0)
	result_title = title
	result_message = message if message != "" else "Team Score: %d\nP1 Score: %d   P2 Score: %d\nPress R to return to Home" % [team_score, p1_score, p2_score]
	banner_label.text = ""
	game_over_layer.visible = true
	game_over_title.text = result_title
	game_over_detail.text = result_message
