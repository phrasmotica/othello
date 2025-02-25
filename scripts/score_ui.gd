@tool
class_name ScoreUI extends VBoxContainer

@onready
var black_score_panel: ScorePanel = %BlackScorePanel

@onready
var white_score_panel: ScorePanel = %WhiteScorePanel

@onready
var result_panel: ResultPanel = %ResultPanel

func _ready() -> void:
	if not Engine.is_editor_hint():
		if result_panel:
			result_panel.hide()

func update_ui(black_score: int, white_score: int, result: OthelloScore.GameResult) -> void:
	black_score_panel.score = black_score
	white_score_panel.score = white_score

	result_panel.result = result

func handle_next_colour_changed(colour: BoardStateData.CounterType) -> void:
	black_score_panel.is_highlighted = colour == BoardStateData.CounterType.BLACK
	white_score_panel.is_highlighted = colour == BoardStateData.CounterType.WHITE

func handle_game_ended() -> void:
	black_score_panel.is_highlighted = false
	white_score_panel.is_highlighted = false

	if result_panel:
		result_panel.show()

func handle_game_restarted() -> void:
	if result_panel:
		result_panel.hide()
