@tool
class_name GameUI extends VBoxContainer

@export
var starting_animation: StringName

@export
var game_logic: OthelloGameLogic

@onready
var score_ui: ScoreUI = %ScoreUI

@onready
var buttons: GameButtons = %GameButtons

@onready
var animation_player: AnimationPlayer = %AnimationPlayer

signal starting_animation_finished
signal toggled_settings
signal quit_to_main_menu

func _ready() -> void:
	if game_logic:
		SignalHelper.persist(game_logic.score_changed, score_ui.update_ui)
		SignalHelper.persist(game_logic.next_colour_changed, score_ui.handle_next_colour_changed)
		SignalHelper.persist(game_logic.game_ended, score_ui.handle_game_ended)
		SignalHelper.persist(game_logic.game_restarted, score_ui.handle_game_restarted)

		if not Engine.is_editor_hint():
			SignalHelper.persist(buttons.restarted, game_logic.restart_game)
			SignalHelper.chain(buttons.toggle_settings, toggled_settings)
			SignalHelper.chain(buttons.quit_to_main_menu, quit_to_main_menu)

	if animation_player:
		SignalHelper.persist(animation_player.animation_finished, _handle_animation_finished)

func anim_in() -> void:
	SignalHelper.once_next_frame(show)

	animation_player.play(starting_animation)

func _handle_animation_finished(anim_name: StringName) -> void:
	if anim_name == starting_animation:
		starting_animation_finished.emit()
