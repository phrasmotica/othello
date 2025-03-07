class_name InputHandler extends Node

@export
var entrance: EntranceOrchestrator

@export
var counter_box: CounterBox

@export
var camera_rig_animation: AnimationPlayer

@export
var game_logic: OthelloGameLogic

signal toggled_settings

func _ready() -> void:
	set_process(false)

	if entrance:
		SignalHelper.once(entrance.finished, set_process.bind(true))
	else:
		set_process(true)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("peek_counter_box"):
		if counter_box:
			SignalHelper.once(counter_box.peek_finished, _handle_peek_finished)
			counter_box.peek()

		if camera_rig_animation:
			camera_rig_animation.play("peek_box")

	if Input.is_action_just_released("peek_counter_box"):
		if counter_box:
			counter_box.unpeek()

		if camera_rig_animation:
			camera_rig_animation.play_backwards("peek_box")

	if Input.is_action_just_pressed("toggle_settings_menu"):
		toggled_settings.emit()

	if Input.is_action_just_pressed("restart_game"):
		if game_logic:
			game_logic.restart_game()

func _handle_peek_finished() -> void:
	if not Input.is_action_pressed("peek_counter_box"):
		counter_box.unpeek()
