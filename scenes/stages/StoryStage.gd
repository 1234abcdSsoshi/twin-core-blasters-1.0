# res://scenes/stages/StoryStage.gd
# ------------------------------------------------------------
# StoryStage controls Story Mode.
#
# Current transition design:
# - start_stage() calls Main.gd's existing _start_story().
# - update_stage() calls Main.gd's existing _update_story(delta).
#
# Step C implementation note:
# The current project still keeps the active gameplay logic in Main.gd.
# Therefore, P1/P2 individuality, personalized item effects, and Fusion Mode
# have been implemented in Main.gd for this step so the game can keep running
# without a risky full migration.
#
# Implemented gameplay design:
# - P1 Azure Wing: fast movement, quick precision shots, piercing laser on Power Boost.
# - P2 Solar Fang: slower movement, heavy shots, 3-shot burst on Rapid Fire, longer Shield.
# - Fusion Mode: Link Charge or 100% Co-op Link activates Twin Core Fusion.
#   P1 controls aim + cannon with WASD/F.
#   P2 controls movement + shield with Arrow keys/L.
#
# Next refactor step:
# Move these Story-specific functions from Main.gd into this file:
# - _update_story()
# - _shoot() Story Mode branch
# - _apply_item() Story Mode branch
# - _activate_story_fusion()
# - _update_story_fusion()
# - _deactivate_story_fusion()
# ------------------------------------------------------------
class_name StoryStage
extends StageBase

func _init() -> void:
	stage_name = "Story Mode"

func start_stage() -> void:
	print("[StoryStage] start")
	if host != null and host.has_method("_start_story"):
		host._start_story()

func update_stage(delta: float) -> void:
	if host != null and host.has_method("_update_story"):
		host._update_story(delta)
