@tool
class_name ScoreUI extends VBoxContainer

@export
var board: Board

@onready
var black_score_label: Label = %BlackScoreLabel

@onready
var white_score_label: Label = %WhiteScoreLabel

func _ready() -> void:
	if board:
		board.score_changed.connect(_update_ui)

func _update_ui(black_score: int, white_score: int) -> void:
	black_score_label.text = "Black: %d" % black_score
	white_score_label.text = "White: %d" % white_score
