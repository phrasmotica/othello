extends Node

@export
var board: Board3D

@export
var counter_box: CounterBox

@export
var debug_canvas: CanvasLayer

var _is_debug := false

func _ready() -> void:
	if Engine.is_editor_hint():
		return

	SignalHelper.persist(Globals.toggled_debug_mode, _handle_toggled_debug_mode)

	_refresh()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("place_counter_debug"):
		if board:
			if counter_box:
				counter_box.take_top()

			board.play_random()

func _handle_toggled_debug_mode(is_debug: bool) -> void:
	_is_debug = is_debug

	_refresh()

func _refresh() -> void:
	set_process(_is_debug)

	if counter_box:
		counter_box.debug_mode = _is_debug

	if debug_canvas:
		debug_canvas.visible = _is_debug
