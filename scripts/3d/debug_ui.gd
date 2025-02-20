extends VBoxContainer

@export
var board: Board3D

@onready
var board_busy_label: Label = %BoardBusyLabel

func _ready() -> void:
	if board:
		SignalHelper.persist(board.busy_changed, _handle_board_busy_changed)

func _handle_board_busy_changed(is_busy: bool) -> void:
	if board_busy_label:
		board_busy_label.text = "Board busy: %s" % is_busy
