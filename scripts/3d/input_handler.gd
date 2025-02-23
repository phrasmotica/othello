extends Node

@export
var entrance: EntranceOrchestrator

@export
var counter_box: CounterBox

@export
var settings_menu: SettingsMenu3D

@export
var camera_rig_animation: AnimationPlayer

func _ready() -> void:
	set_process(false)

	if entrance:
		SignalHelper.once(entrance.finished, set_process.bind(true))
	else:
		set_process(true)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("peek_counter_box"):
		if counter_box:
			counter_box.peek()

		if camera_rig_animation:
			camera_rig_animation.play("peek_box")

	if Input.is_action_just_released("peek_counter_box"):
		if counter_box:
			counter_box.unpeek()

		if camera_rig_animation:
			camera_rig_animation.play_backwards("peek_box")

	if Input.is_action_just_pressed("toggle_settings_menu"):
		if settings_menu:
			settings_menu.toggle_menu()
