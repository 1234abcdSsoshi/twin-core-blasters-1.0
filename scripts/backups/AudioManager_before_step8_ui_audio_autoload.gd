extends Node

const AssetPaths = preload("res://scripts/AssetPaths.gd")

var bgm_player: AudioStreamPlayer
var shield_loop_player: AudioStreamPlayer
var current_bgm_key: String = ""

func _ready() -> void:
	_ensure_players()

func _ensure_players() -> void:
	if bgm_player == null:
		bgm_player = AudioStreamPlayer.new()
		bgm_player.bus = "Master"
		add_child(bgm_player)
	if shield_loop_player == null:
		shield_loop_player = AudioStreamPlayer.new()
		shield_loop_player.bus = "Master"
		add_child(shield_loop_player)

func play_bgm(key: String, volume_db: float = -8.0) -> void:
	_ensure_players()
	if current_bgm_key == key and bgm_player.playing:
		return
	if not AssetPaths.BGM.has(key):
		push_warning("BGM key not found: " + key)
		return
	var path: String = AssetPaths.BGM[key]
	if not ResourceLoader.exists(path):
		push_warning("BGM file not found: " + path)
		return
	current_bgm_key = key
	bgm_player.stop()
	bgm_player.stream = load(path)
	bgm_player.volume_db = volume_db
	bgm_player.play()

func stop_bgm() -> void:
	_ensure_players()
	current_bgm_key = ""
	bgm_player.stop()

func play_sfx(key: String, volume_db: float = -4.0) -> void:
	_ensure_players()
	if not AssetPaths.SFX.has(key):
		push_warning("SFX key not found: " + key)
		return
	var path: String = AssetPaths.SFX[key]
	if not ResourceLoader.exists(path):
		push_warning("SFX file not found: " + path)
		return
	var player := AudioStreamPlayer.new()
	player.bus = "Master"
	player.stream = load(path)
	player.volume_db = volume_db
	add_child(player)
	player.play()
	player.finished.connect(player.queue_free)

func start_shield_loop() -> void:
	_ensure_players()
	if not AssetPaths.SFX.has("shield_loop"):
		return
	var path: String = AssetPaths.SFX["shield_loop"]
	if not ResourceLoader.exists(path):
		return
	if shield_loop_player.playing:
		return
	shield_loop_player.stream = load(path)
	shield_loop_player.volume_db = -16.0
	shield_loop_player.play()

func stop_shield_loop() -> void:
	_ensure_players()
	if shield_loop_player.playing:
		shield_loop_player.stop()
