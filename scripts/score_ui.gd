@tool
class_name ScoreUI extends VBoxContainer

@export
var game_logic: OthelloGameLogic

@onready
var black_score_label: Label = %BlackScoreLabel

@onready
var white_score_label: Label = %WhiteScoreLabel

@onready
var info_label: Label = %InfoLabel

var _colour_names := {
	BoardStateData.CounterType.BLACK: "Black",
	BoardStateData.CounterType.WHITE: "White",
}

var _result := OthelloScore.GameResult.DRAW

func _ready() -> void:
	if game_logic:
		game_logic.score_changed.connect(_update_ui)
		game_logic.next_colour_changed.connect(_handle_next_colour_changed)
		game_logic.game_ended.connect(_handle_game_ended)

func _update_ui(black_score: int, white_score: int, result: OthelloScore.GameResult) -> void:
	black_score_label.text = str(black_score)
	white_score_label.text = str(white_score)

	_result = result

func _handle_next_colour_changed(colour: BoardStateData.CounterType) -> void:
	info_label.text = "It is %s's turn..." % _colour_names[colour]

func _handle_game_ended() -> void:
	var text := "It's a draw."

	if _result == OthelloScore.GameResult.BLACK_WINS:
		text = "Black wins!"

	if _result == OthelloScore.GameResult.WHITE_WINS:
		text = "White wins!"

	info_label.text = text
