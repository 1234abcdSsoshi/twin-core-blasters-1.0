# res://scenes/ui/ResultScreen.gd
# ------------------------------------------------------------
# Future result screen script.
#
# Main.gd currently shows the result screen directly.
# This script is included so the result UI can be separated later.
# ------------------------------------------------------------
class_name ResultScreen
extends Control

signal retry_requested
signal home_requested

func request_retry() -> void:
	retry_requested.emit()

func request_home() -> void:
	home_requested.emit()
