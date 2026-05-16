# res://scenes/stages/AstralCourtStage.gd
# ------------------------------------------------------------
# AstralCourtStage controls the 2-player duel stage.
#
# Current transition design:
# - start_stage() calls Main.gd's existing _start_astral_court().
# - update_stage() calls Main.gd's existing _update_astral_court(delta).
#
# Next refactor step:
# Move Astral Court-specific variables and functions from Main.gd into this file.
# Example targets:
# - arena_time
# - arena_p1_hp / arena_p2_hp
# - p1_core / p2_core
# - dash / shield / ultimate logic
# - obstacle logic
# - duel result logic
# ------------------------------------------------------------
class_name AstralCourtStage
extends StageBase

func _init() -> void:
	stage_name = "Astral Court"

func start_stage() -> void:
	print("[AstralCourtStage] start")
	if host != null and host.has_method("_start_astral_court"):
		host._start_astral_court()

func update_stage(delta: float) -> void:
	if host != null and host.has_method("_update_astral_court"):
		host._update_astral_court(delta)
