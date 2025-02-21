class_name CameraRigToBoxAnimation extends Node

@export
var camera_rig_animation: AnimationPlayer

@export
var camera_rig: CameraRig

signal finished_in
signal finished_out

func anim_in() -> void:
	SignalHelper.once(camera_rig_animation.animation_finished, _handle_finished_in)

	camera_rig_animation.play("to_box")

func anim_out() -> void:
	SignalHelper.once(camera_rig_animation.animation_finished, _handle_finished_out)

	camera_rig_animation.play_backwards("to_box")

func _handle_finished_in(_anim_name: StringName) -> void:
	finished_in.emit()

func _handle_finished_out(_anim_name: StringName) -> void:
	finished_out.emit()
