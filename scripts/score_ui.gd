@tool
class_name ScoreUI extends VBoxContainer

@export
var starting_animation: StringName

@export
var game_logic: OthelloGameLogic

@onready
var black_score_panel: ScorePanel = %BlackScorePanel

@onready
var white_score_panel: ScorePanel = %WhiteScorePanel

@onready
var info_label: Label = %InfoLabel

@onready
var animation_player: AnimationPlayer = %AnimationPlayer

var _colour_names := {
	BoardStateData.CounterType.BLACK: "Black",
	BoardStateData.CounterType.WHITE: "White",
}

var _result := OthelloScore.GameResult.DRAW

signal starting_animation_finished

func _ready() -> void:
	if game_logic:
		game_logic.score_changed.connect(_update_ui)
		game_logic.next_colour_changed.connect(_handle_next_colour_changed)
		game_logic.game_ended.connect(_handle_game_ended)

	if not Engine.is_editor_hint():
		if animation_player:
			SignalHelper.persist(animation_player.animation_finished, _handle_animation_finished)

func anim_in() -> void:
	SignalHelper.once_next_frame(show)

	animation_player.play(starting_animation)

func _handle_animation_finished(anim_name: StringName) -> void:
	if anim_name == starting_animation:
		starting_animation_finished.emit()

func _update_ui(black_score: int, white_score: int, result: OthelloScore.GameResult) -> void:
	black_score_panel.score = black_score
	white_score_panel.score = white_score

	_result = result

func _handle_next_colour_changed(colour: BoardStateData.CounterType) -> void:
	black_score_panel.is_highlighted = colour == BoardStateData.CounterType.BLACK
	white_score_panel.is_highlighted = colour == BoardStateData.CounterType.WHITE

	info_label.text = "It is %s's turn..." % _colour_names[colour]

func _handle_game_ended() -> void:
	var text := "It's a draw."

	if _result == OthelloScore.GameResult.BLACK_WINS:
		text = "Black wins!"

	if _result == OthelloScore.GameResult.WHITE_WINS:
		text = "White wins!"

	info_label.text = text
