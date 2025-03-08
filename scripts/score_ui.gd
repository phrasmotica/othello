@tool
class_name ScoreUI extends VBoxContainer

@export
var auto_skip_turn := false

@onready
var black_score_panel: ScorePanel = %BlackScorePanel

@onready
var white_score_panel: ScorePanel = %WhiteScorePanel

@onready
var turn_indicator_panel: TurnIndicatorPanel = %TurnIndicatorPanel

@onready
var progress_bar: ProgressBar = %ProgressBar

@onready
var continue_button: Button = %ContinueButton

@onready
var result_panel: ResultPanel = %ResultPanel

var _turn_skip_duration := 3.0

signal continued

func _ready() -> void:
	if Engine.is_editor_hint():
		return

	if result_panel:
		result_panel.hide()

	if progress_bar:
		progress_bar.hide()

	if continue_button:
		SignalHelper.chain(continue_button.pressed, continued)

		continue_button.hide()

	if turn_indicator_panel:
		turn_indicator_panel.hide()

func update_ui(black_score: int, white_score: int, result: OthelloScore.GameResult) -> void:
	black_score_panel.score = black_score
	white_score_panel.score = white_score

	result_panel.result = result

func handle_next_turn_started(type: TurnTracker.TurnType) -> void:
	turn_indicator_panel.turn_type = type

	if [TurnTracker.TurnType.BLACK_PLAY, TurnTracker.TurnType.BLACK_SKIP].has(type):
		black_score_panel.is_highlighted = true
		white_score_panel.is_highlighted = false

	if [TurnTracker.TurnType.WHITE_PLAY, TurnTracker.TurnType.WHITE_SKIP].has(type):
		black_score_panel.is_highlighted = false
		white_score_panel.is_highlighted = true

	_handle_turn_type(type)

func _handle_turn_type(type: TurnTracker.TurnType) -> void:
	if [TurnTracker.TurnType.BLACK_PLAY, TurnTracker.TurnType.WHITE_PLAY].has(type):
		turn_indicator_panel.hide()
		progress_bar.hide()
		continue_button.hide()
		return

	# turn is being skipped
	turn_indicator_panel.show()

	if auto_skip_turn:
		progress_bar.show()

		_tween_progress_bar()
	else:
		continue_button.show()

func _tween_progress_bar() -> void:
	progress_bar.value = progress_bar.min_value

	var tween = create_tween()

	tween.tween_property(
		progress_bar,
		"value",
		progress_bar.max_value,
		_turn_skip_duration
	)

	tween.tween_callback(progress_bar.hide)

	SignalHelper.chain_once(tween.finished, continued)

func handle_game_ended() -> void:
	black_score_panel.is_highlighted = false
	white_score_panel.is_highlighted = false

	if result_panel:
		result_panel.show()

func handle_game_restarted() -> void:
	if result_panel:
		result_panel.hide()
