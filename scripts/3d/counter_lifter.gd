@tool
class_name CounterLifter extends Node

enum AnimationState { IDLE, LIFTING, HOLDING, DROPPING }

@export
var target_counter: Counter3D

@export_range(0.5, 1.0)
var lift_height := 0.5

@export_range(0.1, 0.5)
var lift_duration := 0.5

var _animation_state: AnimationState

func lift() -> void:
	if not target_counter:
		return

	if not _validate_transition(AnimationState.IDLE, AnimationState.LIFTING):
		return

	target_counter.disable_rigid_body()

	var tween := create_tween()

	tween.tween_property(
		target_counter,
		"position:y",
		target_counter.position.y + lift_height,
		lift_duration
	)

	_set_state_on(tween.finished, AnimationState.HOLDING)

func drop() -> void:
	if not target_counter:
		return

	if not _validate_transition(AnimationState.HOLDING, AnimationState.DROPPING):
		return

	target_counter.enable_rigid_body()

	_set_state_on(target_counter.landed_on_board, AnimationState.IDLE)

func _validate_transition(required: AnimationState, next: AnimationState) -> bool:
	if _animation_state != required:
		return false

	_animation_state = next
	return true

func _set_state_on(sig: Signal, anim_state: AnimationState) -> void:
	var callable := _set_state.bind(anim_state)

	if not sig.is_connected(callable):
		sig.connect(callable, CONNECT_ONE_SHOT)

func _set_state(anim_state: AnimationState) -> void:
	_animation_state = anim_state
