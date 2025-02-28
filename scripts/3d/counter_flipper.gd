@tool
class_name CounterFlipper extends Node

enum AnimationState { IDLE, FLIPPING }

@export
var target_counter: Counter3D

@export
var counter_lifter: CounterLifter

@export_range(0.1, 0.5)
var flip_duration := 0.5

var _animation_state: AnimationState
var _tween: Tween
var _is_rotated_to_white := false

signal flip_started
signal flip_finished

func _ready() -> void:
	if target_counter:
		target_counter.refreshed.connect(_handle_refreshed)
		target_counter.needs_flip.connect(_flip_counter)

func _handle_refreshed() -> void:
	if target_counter:
		_is_rotated_to_white = target_counter.is_white

func stop_animations() -> void:
	if _tween:
		_tween.stop()
		_tween.kill()

		flip_finished.emit()

func _flip_counter(flippable: Node3D, flip_delay: float) -> void:
	if _is_rotated_to_white == target_counter.is_white:
		return

	if not flippable:
		return

	if not _validate_transition(AnimationState.IDLE, AnimationState.FLIPPING):
		return

	var flip_callable := _do_flip.bind(flippable, flip_delay)

	if counter_lifter:
		SignalHelper.once(counter_lifter.lift_finished, flip_callable)
		counter_lifter.lift()
	else:
		flip_callable.call()

func _do_flip(flippable: Node3D, flip_delay: float) -> void:
	flip_started.emit()

	flippable.set_meta("debug_name", "%sFlippable" % target_counter.debug_name)

	_rotate_tween(flippable, flip_delay)

func _rotate_tween(flippable: Node3D, delay: float) -> void:
	var final_rotation := int(flippable.rotation_degrees.x + 180) % 360

	_tween = create_tween()

	_tween.tween_property(
		flippable,
		"rotation_degrees:x",
		final_rotation,
		flip_duration
	).set_delay(delay)

	var callable := _handle_finished.bind(flippable, final_rotation)
	SignalHelper.once(_tween.finished, callable)

func _handle_finished(flippable: Node3D, final_rotation: float) -> void:
	flippable.rotation_degrees.x = final_rotation

	var debug_name := flippable.get_meta("debug_name") as String
	print("Finished rotating %s to %.1f" % [debug_name, final_rotation])

	_is_rotated_to_white = target_counter.is_white
	_animation_state = AnimationState.IDLE

	flip_finished.emit()

func _validate_transition(required: AnimationState, next: AnimationState) -> bool:
	if _animation_state != required:
		return false

	_animation_state = next
	return true
