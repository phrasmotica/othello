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
var result_panel: ResultPanel = %ResultPanel

@onready
var animation_player: AnimationPlayer = %AnimationPlayer

signal starting_animation_finished

func _ready() -> void:
	if game_logic:
		game_logic.score_changed.connect(_update_ui)
		game_logic.next_colour_changed.connect(_handle_next_colour_changed)
		game_logic.game_ended.connect(_handle_game_ended)
		game_logic.game_restarted.connect(_handle_game_restarted)

	if not Engine.is_editor_hint():
		if result_panel:
			result_panel.hide()

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

	result_panel.result = result

func _handle_next_colour_changed(colour: BoardStateData.CounterType) -> void:
	black_score_panel.is_highlighted = colour == BoardStateData.CounterType.BLACK
	white_score_panel.is_highlighted = colour == BoardStateData.CounterType.WHITE

func _handle_game_ended() -> void:
	black_score_panel.is_highlighted = false
	white_score_panel.is_highlighted = false

	if result_panel:
		result_panel.show()

func _handle_game_restarted() -> void:
	if result_panel:
		result_panel.hide()
