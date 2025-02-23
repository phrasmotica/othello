class_name CounterSpawner extends Marker3D

@export
var counter_scene: PackedScene

@export
var spawn_amount := 10

@export_range(0.05, 0.3)
var spawn_interval := 0.1

@export_range(10.0, 30.0)
var spawn_force := 20.0

@export_range(0.01, 0.1)
var counter_sleep_threshold := 0.05

var _counters: Array[Counter3D] = []

signal finished

func spawn_counters() -> void:
	if not counter_scene:
		return

	for c in _counters:
		c.queue_free()

	_counters.clear()

	for i in spawn_amount:
		var counter: Counter3D = counter_scene.instantiate()
		counter.position = position + _get_offset()
		counter.rotation = _get_rotation_offset()

		var rb := counter.get_child(0) as RigidBody3D
		rb.apply_impulse(spawn_force * Vector3.DOWN)

		SignalHelper.once(
			counter.landed_on_board,
			_counters.append.bind(counter)
		)

		add_child(counter)

		await get_tree().create_timer(spawn_interval).timeout

	SignalHelper.once(get_tree().create_timer(1.0).timeout, _emit_finished)

func get_counters() -> Array[Counter3D]:
	return _counters

func _physics_process(_delta: float) -> void:
	for c in _counters:
		var rb := c.get_child(0) as RigidBody3D

		if not rb.sleeping and _should_sleep(rb):
			rb.sleeping = true

func _should_sleep(rb: RigidBody3D) -> bool:
	return (
		rb.linear_velocity.length() < counter_sleep_threshold
		# and rb.angular_velocity.length() < counter_sleep_threshold
	)

func _get_offset() -> Vector3:
	var x_extent := 2.0
	var z_extent := 0.6

	var x_offset := x_extent * 2.0 * (randf() - 0.5)
	var z_offset := z_extent * 2.0 * (randf() - 0.5)

	return Vector3(x_offset, 0, z_offset)

func _get_rotation_offset() -> Vector3:
	var extent := PI

	var x_offset := extent * 2.0 * (randf() - 0.5)
	var y_offset := extent * 2.0 * (randf() - 0.5)
	var z_offset := extent * 2.0 * (randf() - 0.5)

	return Vector3(x_offset, y_offset, z_offset)

func _emit_finished() -> void:
	for c in _counters:
		var rb := c.get_child(0) as RigidBody3D

		rb.freeze = true

	finished.emit()
