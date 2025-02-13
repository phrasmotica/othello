class_name DebugHandler extends Node

@export
var board: Board

var _is_debug := false

func _ready() -> void:
	Globals.toggled_debug_mode.connect(_handle_toggled_debug_mode)

func _process(_delta: float) -> void:
	if not _is_debug:
		return

	if Input.is_action_just_pressed("place_counter_debug"):
		if board:
			board.play_random()

func _handle_toggled_debug_mode(is_debug: bool) -> void:
	_is_debug = is_debug
