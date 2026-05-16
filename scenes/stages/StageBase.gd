# res://scenes/stages/StageBase.gd
# ------------------------------------------------------------
# StageBase is the shared parent class for all stage controller files.
#
# This first refactor step is intentionally small:
# - Main.gd still owns the existing gameplay functions.
# - Each stage file calls the corresponding existing Main.gd functions.
# - Later, we will gradually move the real logic from Main.gd into each stage.
#
# This approach lets us split the project safely without breaking the game at once.
# ------------------------------------------------------------
class_name StageBase
extends Node2D

# Sent when a stage wants Main.gd to show the result screen or return to title.
# We will use this more in the next refactor step.
signal stage_finished(result: Dictionary)

# Reference to the current Main node.
# In this transition step, the stage calls existing Main.gd methods through this.
var host: Node = null

# Human-readable stage name for debug output and future UI use.
var stage_name: String = "StageBase"

func setup_stage(main_node: Node) -> void:
	# Store the Main node reference.
	# Later, we will reduce this dependency after moving logic into stage files.
	host = main_node
	print("[StageBase] setup: ", stage_name)

func start_stage() -> void:
	# Child classes override this.
	pass

func update_stage(delta: float) -> void:
	# Child classes override this.
	pass

func finish_stage(result: Dictionary) -> void:
	# Common stage-finished signal.
	stage_finished.emit(result)
