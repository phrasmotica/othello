@tool
class_name TurnIndicatorPanel extends PanelContainer

@export
var turn_type: TurnTracker.TurnType:
	set(value):
		turn_type = value

		_refresh()

@export
var show_skipped := false:
	set(value):
		show_skipped = value

		_refresh()

@onready
var label: Label = %Label

func _refresh() -> void:
	theme_type_variation = _compute_theme_type()

	if label:
		label.text = _compute_text()
		label.theme_type_variation = _compute_label_theme_type()

func _compute_text() -> String:
	if turn_type == TurnTracker.TurnType.BLACK_PLAY:
		return "Black to play..."

	if turn_type == TurnTracker.TurnType.WHITE_PLAY:
		return "White to play..."

	if turn_type == TurnTracker.TurnType.BLACK_SKIP:
		return "Black cannot play!"

	if turn_type == TurnTracker.TurnType.WHITE_SKIP:
		return "White cannot play!"

	return "Both colours cannot play!"

func _compute_theme_type() -> String:
	if turn_type == TurnTracker.TurnType.BLACK_PLAY\
	or turn_type == TurnTracker.TurnType.BLACK_SKIP:
		return "BlackScorePanel"

	if turn_type == TurnTracker.TurnType.WHITE_PLAY\
	or turn_type == TurnTracker.TurnType.WHITE_SKIP:
		return "WhiteScorePanel"

	return "DrawScorePanel"

func _compute_label_theme_type() -> String:
	if turn_type == TurnTracker.TurnType.BLACK_PLAY\
	or turn_type == TurnTracker.TurnType.BLACK_SKIP:
		return "BlackScoreLabel"

	if turn_type == TurnTracker.TurnType.WHITE_PLAY\
	or turn_type == TurnTracker.TurnType.WHITE_SKIP:
		return "WhiteScoreLabel"

	return "DrawScoreLabel"
