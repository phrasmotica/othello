@tool
class_name ScoreUI extends VBoxContainer

@onready
var black_score_panel: ScorePanel = %BlackScorePanel

@onready
var white_score_panel: ScorePanel = %WhiteScorePanel

@onready
var turn_indicator_panel: TurnIndicatorPanel = %TurnIndicatorPanel

@onready
var result_panel: ResultPanel = %ResultPanel

func _ready() -> void:
	if not Engine.is_editor_hint():
		if result_panel:
			result_panel.hide()

		if turn_indicator_panel:
			turn_indicator_panel.hide()

func update_ui(black_score: int, white_score: int, result: OthelloScore.GameResult) -> void:
	black_score_panel.score = black_score
	white_score_panel.score = white_score

	result_panel.result = result

func handle_next_turn_started(type: TurnTracker.TurnType) -> void:
	turn_indicator_panel.turn_type = type

	if [TurnTracker.TurnType.BLACK_PLAY, TurnTracker.TurnType.WHITE_PLAY].has(type):
		turn_indicator_panel.hide()
	else:
		turn_indicator_panel.show()

func handle_next_colour_changed(colour: BoardStateData.CounterType) -> void:
	if colour == BoardStateData.CounterType.BLACK:
		black_score_panel.is_highlighted = true
		white_score_panel.is_highlighted = false

		turn_indicator_panel.turn_type = TurnTracker.TurnType.BLACK_PLAY

	if colour == BoardStateData.CounterType.WHITE:
		black_score_panel.is_highlighted = false
		white_score_panel.is_highlighted = true

		turn_indicator_panel.turn_type = TurnTracker.TurnType.WHITE_PLAY

	turn_indicator_panel.hide()

func handle_game_ended() -> void:
	black_score_panel.is_highlighted = false
	white_score_panel.is_highlighted = false

	if result_panel:
		result_panel.show()

func handle_game_restarted() -> void:
	if result_panel:
		result_panel.hide()
