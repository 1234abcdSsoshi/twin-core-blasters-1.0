# res://scripts/input/PlayerInputState.gd
# ------------------------------------------------------------
# Online input abstraction Step 1.
# This class stores one player's input for one frame.
# It is deliberately independent from keyboard keys, so the same data
# can later come from local keyboard input or WebSocket network input.
# ------------------------------------------------------------
class_name PlayerInputState
extends RefCounted

var move: Vector2 = Vector2.ZERO
var aim: Vector2 = Vector2.ZERO
var shoot: bool = false
var bomb: bool = false
var dash: bool = false
var shield: bool = false
var ultimate: bool = false


func clear() -> void:
	move = Vector2.ZERO
	aim = Vector2.ZERO
	shoot = false
	bomb = false
	dash = false
	shield = false
	ultimate = false


func duplicate_state() -> PlayerInputState:
	var state := PlayerInputState.new()
	state.move = move
	state.aim = aim
	state.shoot = shoot
	state.bomb = bomb
	state.dash = dash
	state.shield = shield
	state.ultimate = ultimate
	return state


func to_dictionary() -> Dictionary:
	# This format is JSON-friendly for future WebSocket messages.
	return {
		"move": {"x": move.x, "y": move.y},
		"aim": {"x": aim.x, "y": aim.y},
		"shoot": shoot,
		"bomb": bomb,
		"dash": dash,
		"shield": shield,
		"ultimate": ultimate
	}


static func from_dictionary(data: Dictionary) -> PlayerInputState:
	var state := PlayerInputState.new()

	var move_data: Dictionary = data.get("move", {})
	state.move = Vector2(
		float(move_data.get("x", 0.0)),
		float(move_data.get("y", 0.0))
	)

	var aim_data: Dictionary = data.get("aim", {})
	state.aim = Vector2(
		float(aim_data.get("x", 0.0)),
		float(aim_data.get("y", 0.0))
	)

	state.shoot = bool(data.get("shoot", false))
	state.bomb = bool(data.get("bomb", false))
	state.dash = bool(data.get("dash", false))
	state.shield = bool(data.get("shield", false))
	state.ultimate = bool(data.get("ultimate", false))

	return state
