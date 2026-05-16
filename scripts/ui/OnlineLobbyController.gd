# res://scripts/ui/OnlineLobbyController.gd
# ------------------------------------------------------------
# Step 9-12: オンラインロビーUI Controller
#
# 目的:
# - F10 / F11 / F7 などの開発用キー操作を、ユーザー向けUIに置き換える。
# - ユーザー名入力、ルーム作成、ルーム参加、P1/P2選択、Ready、Start Gameを扱う。
# - ネットワーク処理そのものはMain.gd / NetworkClient.gdに任せ、このクラスはUIだけを担当する。
# ------------------------------------------------------------
class_name OnlineLobbyController
extends CanvasLayer

signal connect_requested(player_name: String)
signal create_room_requested(player_name: String)
signal join_room_requested(player_name: String, room_code: String)
signal role_selected(role: String)
signal ready_requested(ready: bool)
signal start_game_requested
signal close_requested

var screen_size: Vector2 = Vector2(1920, 1080)

var dim: ColorRect
var panel: ColorRect
var title_label: Label
var status_label: Label
var room_label: Label
var name_edit: LineEdit
var code_edit: LineEdit
var connect_button: Button
var create_button: Button
var join_button: Button
var back_button: Button
var p1_card: Button
var p2_card: Button
var p1_image: TextureRect
var p2_image: TextureRect
var p1_state_label: Label
var p2_state_label: Label
var ready_button: Button
var start_button: Button

var current_room_id: String = ""
var local_player_id: int = 0
var local_ready: bool = false
var current_page: String = "lobby"


func _ready() -> void:
	# タイトル画面より前面に出すため、CanvasLayerのlayerを高くします。
	# Main.gd側でも設定しますが、ここでも指定して二重に安全化します。
	layer = 80

	# CanvasLayerはvisibleを持たないため、子ノードを一括で表示/非表示にします。
	screen_size = get_viewport().get_visible_rect().size
	_build_ui()
	close_lobby()


func open_lobby(server_url: String) -> void:
	# タイトル画面から呼ばれる入口です。
	_set_all_visible(true)
	_show_lobby_page()
	set_status_message("Server: " + server_url)


func close_lobby() -> void:
	_set_all_visible(false)


func set_network_status(status: String) -> void:
	status_label.text = "Status: " + status


func set_status_message(message: String) -> void:
	status_label.text = message


func set_room_id(room_id: String) -> void:
	current_room_id = room_id
	if current_room_id == "":
		room_label.text = "Room: -"
	else:
		room_label.text = "Room: " + current_room_id


func set_local_player(player_id: int) -> void:
	local_player_id = player_id
	_update_card_visuals()


func apply_room_state(room_state: Dictionary) -> void:
	# サーバーから届いた部屋情報を反映します。
	# room_state.players.p1 / p2 に name, ready, occupied が入ります。
	if room_state.has("room_id"):
		set_room_id(str(room_state.get("room_id", "")))

	var players: Dictionary = room_state.get("players", {})
	var p1: Dictionary = players.get("p1", {})
	var p2: Dictionary = players.get("p2", {})

	p1_state_label.text = _format_player_state("P1 Azure Wing", p1)
	p2_state_label.text = _format_player_state("P2 Solar Fang", p2)

	# Start Gameはホストだけ押せる想定です。
	# サーバー側で拒否もするため、UI側は分かりやすくする目的です。
	var can_start := bool(room_state.get("can_start", false))
	var host_player := int(room_state.get("host_player_id", 0))
	start_button.disabled = not (can_start and local_player_id == host_player)

	_update_card_visuals()
	_show_waiting_page()


func _format_player_state(label_text: String, data: Dictionary) -> String:
	var occupied := bool(data.get("occupied", false))
	if not occupied:
		return label_text + "\nEMPTY"
	var name := str(data.get("name", "Player"))
	var ready := bool(data.get("ready", false))
	return label_text + "\n" + name + "\n" + ("READY" if ready else "NOT READY")


func _set_all_visible(enabled: bool) -> void:
	for child in get_children():
		if child is CanvasItem:
			(child as CanvasItem).visible = enabled


func _build_ui() -> void:
	# 背景の暗幕です。
	dim = ColorRect.new()
	dim.position = Vector2.ZERO
	dim.size = screen_size
	dim.color = Color(0.0, 0.0, 0.0, 0.78)
	add_child(dim)

	panel = ColorRect.new()
	panel.position = Vector2(screen_size.x * 0.5 - 650.0, screen_size.y * 0.5 - 390.0)
	panel.size = Vector2(1300.0, 780.0)
	panel.color = Color(0.018, 0.035, 0.075, 0.96)
	add_child(panel)

	title_label = _make_label("ONLINE LOBBY", Vector2(panel.position.x, panel.position.y + 28.0), Vector2(panel.size.x, 70.0), 52, Color(0.24, 1.0, 0.86), HORIZONTAL_ALIGNMENT_CENTER)
	add_child(title_label)

	status_label = _make_label("Status: offline", Vector2(panel.position.x + 60.0, panel.position.y + 100.0), Vector2(panel.size.x - 120.0, 40.0), 24, Color(0.88, 0.95, 1.0), HORIZONTAL_ALIGNMENT_CENTER)
	add_child(status_label)

	room_label = _make_label("Room: -", Vector2(panel.position.x + 60.0, panel.position.y + 145.0), Vector2(panel.size.x - 120.0, 42.0), 32, Color(1.0, 0.88, 0.28), HORIZONTAL_ALIGNMENT_CENTER)
	add_child(room_label)

	name_edit = LineEdit.new()
	name_edit.position = Vector2(panel.position.x + 210.0, panel.position.y + 230.0)
	name_edit.size = Vector2(380.0, 58.0)
	name_edit.placeholder_text = "Player Name"
	name_edit.text = "Player"
	name_edit.add_theme_font_size_override("font_size", 28)
	add_child(name_edit)

	code_edit = LineEdit.new()
	code_edit.position = Vector2(panel.position.x + 710.0, panel.position.y + 230.0)
	code_edit.size = Vector2(260.0, 58.0)
	code_edit.placeholder_text = "Room Code"
	code_edit.max_length = 8
	code_edit.add_theme_font_size_override("font_size", 28)
	add_child(code_edit)

	connect_button = _make_button("CONNECT", Vector2(panel.position.x + 100.0, panel.position.y + 325.0), Vector2(250.0, 66.0))
	connect_button.pressed.connect(_on_connect_pressed)
	add_child(connect_button)

	create_button = _make_button("CREATE ROOM", Vector2(panel.position.x + 390.0, panel.position.y + 325.0), Vector2(270.0, 66.0))
	create_button.pressed.connect(_on_create_pressed)
	add_child(create_button)

	join_button = _make_button("JOIN ROOM", Vector2(panel.position.x + 700.0, panel.position.y + 325.0), Vector2(250.0, 66.0))
	join_button.pressed.connect(_on_join_pressed)
	add_child(join_button)

	back_button = _make_button("BACK", Vector2(panel.position.x + 990.0, panel.position.y + 325.0), Vector2(210.0, 66.0))
	back_button.pressed.connect(_on_back_pressed)
	add_child(back_button)

	p1_card = _make_button("", Vector2(panel.position.x + 110.0, panel.position.y + 430.0), Vector2(500.0, 240.0))
	p1_card.pressed.connect(func(): role_selected.emit("p1"))
	add_child(p1_card)

	p2_card = _make_button("", Vector2(panel.position.x + 690.0, panel.position.y + 430.0), Vector2(500.0, 240.0))
	p2_card.pressed.connect(func(): role_selected.emit("p2"))
	add_child(p2_card)

	p1_image = _make_ship_image("res://assets/players/player_azure_wing.png", Vector2(panel.position.x + 150.0, panel.position.y + 465.0))
	add_child(p1_image)
	p2_image = _make_ship_image("res://assets/players/player_solar_fang.png", Vector2(panel.position.x + 730.0, panel.position.y + 465.0))
	add_child(p2_image)

	p1_state_label = _make_label("P1 Azure Wing\nPointer / Cannon", Vector2(panel.position.x + 320.0, panel.position.y + 460.0), Vector2(260.0, 150.0), 28, Color(0.72, 0.95, 1.0), HORIZONTAL_ALIGNMENT_CENTER)
	add_child(p1_state_label)
	p2_state_label = _make_label("P2 Solar Fang\nShip / Bomb", Vector2(panel.position.x + 900.0, panel.position.y + 460.0), Vector2(260.0, 150.0), 28, Color(1.0, 0.82, 0.36), HORIZONTAL_ALIGNMENT_CENTER)
	add_child(p2_state_label)

	ready_button = _make_button("READY", Vector2(panel.position.x + 355.0, panel.position.y + 700.0), Vector2(260.0, 64.0))
	ready_button.pressed.connect(_on_ready_pressed)
	add_child(ready_button)

	start_button = _make_button("START GAME", Vector2(panel.position.x + 685.0, panel.position.y + 700.0), Vector2(300.0, 64.0))
	start_button.disabled = true
	start_button.pressed.connect(func(): start_game_requested.emit())
	add_child(start_button)

	_show_lobby_page()


func _show_lobby_page() -> void:
	current_page = "lobby"
	p1_card.visible = false
	p2_card.visible = false
	p1_image.visible = false
	p2_image.visible = false
	p1_state_label.visible = false
	p2_state_label.visible = false
	ready_button.visible = false
	start_button.visible = false
	name_edit.visible = true
	code_edit.visible = true
	connect_button.visible = true
	create_button.visible = true
	join_button.visible = true
	back_button.visible = true


func _show_waiting_page() -> void:
	current_page = "waiting"
	name_edit.visible = false
	code_edit.visible = false
	connect_button.visible = false
	create_button.visible = false
	join_button.visible = false
	back_button.visible = true
	p1_card.visible = true
	p2_card.visible = true
	p1_image.visible = true
	p2_image.visible = true
	p1_state_label.visible = true
	p2_state_label.visible = true
	ready_button.visible = true
	start_button.visible = true


func _on_connect_pressed() -> void:
	connect_requested.emit(name_edit.text)


func _on_create_pressed() -> void:
	create_room_requested.emit(name_edit.text)


func _on_join_pressed() -> void:
	join_room_requested.emit(name_edit.text, code_edit.text)


func _on_back_pressed() -> void:
	# Waiting画面でBACKを押した場合はロビー入力画面へ戻します。
	# ロビー画面で押した場合は閉じます。
	if current_page == "waiting":
		_show_lobby_page()
	else:
		close_requested.emit()


func _on_ready_pressed() -> void:
	local_ready = not local_ready
	ready_button.text = "READY: ON" if local_ready else "READY"
	ready_requested.emit(local_ready)


func _update_card_visuals() -> void:
	# 自分に割り当てられたプレイヤーを少し分かりやすくします。
	p1_card.text = "YOUR ROLE: P1" if local_player_id == 1 else "SELECT P1"
	p2_card.text = "YOUR ROLE: P2" if local_player_id == 2 else "SELECT P2"


func _make_label(text_value: String, pos: Vector2, size_value: Vector2, font_size: int, color: Color, align: HorizontalAlignment) -> Label:
	var label := Label.new()
	label.text = text_value
	label.position = pos
	label.size = size_value
	label.horizontal_alignment = align
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label


func _make_button(text_value: String, pos: Vector2, size_value: Vector2) -> Button:
	var button := Button.new()
	button.text = text_value
	button.position = pos
	button.size = size_value
	button.add_theme_font_size_override("font_size", 26)
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.035, 0.065, 0.13, 0.94)
	normal.border_color = Color(0.25, 0.9, 1.0, 0.72)
	normal.set_border_width_all(2)
	normal.set_corner_radius_all(16)
	button.add_theme_stylebox_override("normal", normal)
	var hover := StyleBoxFlat.new()
	hover.bg_color = Color(0.08, 0.15, 0.24, 0.98)
	hover.border_color = Color(1.0, 0.82, 0.28, 0.95)
	hover.set_border_width_all(3)
	hover.set_corner_radius_all(16)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_color_override("font_color", Color(0.94, 0.98, 1.0))
	button.add_theme_color_override("font_hover_color", Color(1.0, 0.9, 0.28))
	return button


func _make_ship_image(path: String, pos: Vector2) -> TextureRect:
	var rect := TextureRect.new()
	rect.position = pos
	rect.size = Vector2(150.0, 150.0)
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	if ResourceLoader.exists(path):
		rect.texture = load(path)
	return rect
