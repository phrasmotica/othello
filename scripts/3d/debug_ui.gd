extends MarginContainer

@export
var board: Board3D

@onready
var background: Control = %Background

@onready
var board_busy_label: Label = %BoardBusyLabel

@onready
var preview_flips_checkbox: CheckBox = %PreviewFlipsCheckBox

var _board_is_busy := false

func _ready() -> void:
	if board:
		SignalHelper.persist(board.busy_changed, _handle_board_busy_changed)

	if preview_flips_checkbox:
		SignalHelper.persist(preview_flips_checkbox.toggled, _handle_preview_flips_toggled)

	_refresh()

func _handle_board_busy_changed(is_busy: bool) -> void:
	_board_is_busy = is_busy

	_refresh()

func _handle_preview_flips_toggled(is_on: bool) -> void:
	if board:
		board.show_flip_previews = is_on

func _refresh() -> void:
	if background:
		background.visible = _board_is_busy

	if board_busy_label:
		board_busy_label.text = "Board busy: %s" % _board_is_busy
