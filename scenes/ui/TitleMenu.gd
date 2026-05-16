# res://scenes/ui/TitleMenu.gd
# ------------------------------------------------------------
# Future UI scene script.
#
# The current Step 8 build creates the title buttons directly in Main.gd
# to avoid breaking the existing project. This script is included as the
# next migration target, so the title UI can later become its own scene.
# ------------------------------------------------------------
class_name TitleMenu
extends Control

signal story_selected
signal astral_court_selected
signal raid_selected

func emit_story() -> void:
	story_selected.emit()

func emit_astral_court() -> void:
	astral_court_selected.emit()

func emit_raid() -> void:
	raid_selected.emit()
