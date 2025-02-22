@tool
class_name ResultPanel extends PanelContainer

@export
var result: OthelloScore.GameResult:
	set(value):
		result = value

		_refresh()

@onready
var label: Label = %Label

func _refresh() -> void:
	theme_type_variation = _compute_theme_type()

	if label:
		label.text = _compute_text()
		label.theme_type_variation = _compute_label_theme_type()

func _compute_text() -> String:
	if result == OthelloScore.GameResult.BLACK_WINS:
		return "Black wins!"

	if result == OthelloScore.GameResult.WHITE_WINS:
		return "White wins!"

	return "It's a draw."

func _compute_theme_type() -> String:
	if result == OthelloScore.GameResult.BLACK_WINS:
		return "BlackScorePanel"

	if result == OthelloScore.GameResult.WHITE_WINS:
		return "WhiteScorePanel"

	return "DrawScorePanel"

func _compute_label_theme_type() -> String:
	if result == OthelloScore.GameResult.BLACK_WINS:
		return "BlackScoreLabel"

	if result == OthelloScore.GameResult.WHITE_WINS:
		return "WhiteScoreLabel"

	return "DrawScoreLabel"
