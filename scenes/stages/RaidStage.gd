# res://scenes/stages/RaidStage.gd
# ------------------------------------------------------------
# RaidStage controls Eclipse Leviathan Raid.
#
# Current transition design:
# - start_stage() calls Main.gd's existing _start_raid().
# - update_stage() calls Main.gd's existing _update_raid(delta).
#
# Next refactor step:
# Move Raid-specific variables and functions from Main.gd into this file.
# Example targets:
# - raid_phase
# - raid_link
# - raid_boss_hp
# - raid weak-core logic
# - Twin Core Cannon logic
# - raid clear / game-over result logic
# ------------------------------------------------------------
class_name RaidStage
extends StageBase

func _init() -> void:
	stage_name = "Eclipse Leviathan Raid"

func start_stage() -> void:
	print("[RaidStage] start")
	if host != null and host.has_method("_start_raid"):
		host._start_raid()

func update_stage(delta: float) -> void:
	if host != null and host.has_method("_update_raid"):
		host._update_raid(delta)
