@tool
class_name ScoreUI extends VBoxContainer

@export
var score: OthelloScore

@export
var turn_tracker: TurnTracker

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

func _ready() -> void:
	if score:
		score.score_changed.connect(_update_ui)

	if turn_tracker:
		turn_tracker.next_colour_changed.connect(_handle_next_colour_changed)
		turn_tracker.game_ended.connect(_handle_game_ended)

func _update_ui(black_score: int, white_score: int) -> void:
	black_score_label.text = str(black_score)
	white_score_label.text = str(white_score)

func _handle_next_colour_changed(colour: BoardStateData.CounterType) -> void:
	print("ScoreUI _handle_next_colour_changed")
	info_label.text = "It is %s's turn..." % _colour_names[colour]

func _handle_game_ended() -> void:
	print("ScoreUI _handle_game_ended")
	info_label.text = "The game is finished!"
