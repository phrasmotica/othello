extends Node

var _debug_mode := false

var init_finished := false
var auto_skip := false

signal toggled_debug_mode(is_debug: bool)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("toggle_debug_mode"):
		_debug_mode = not _debug_mode

		toggled_debug_mode.emit(_debug_mode)
