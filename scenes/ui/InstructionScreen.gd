# res://scenes/ui/InstructionScreen.gd
# ------------------------------------------------------------
# Future instruction modal script.
#
# Step 8 currently builds a safe instruction modal in Main.gd.
# This script is a clean target for the next UI-scene extraction step.
# ------------------------------------------------------------
class_name InstructionScreen
extends Control

signal start_requested
signal back_requested

var stage_id: String = ""
var stage_title: String = ""
var stage_description: String = ""

func setup_instruction(id: String, title: String, description: String) -> void:
	stage_id = id
	stage_title = title
	stage_description = description

func request_start() -> void:
	start_requested.emit()

func request_back() -> void:
	back_requested.emit()
