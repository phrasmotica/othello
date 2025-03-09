extends Node3D

@onready
var game_scene: PackedScene = load("res://scenes/3d/game_3d.tscn")

@onready
var auto_player: AutoPlayer3D = %AutoPlayer3D

@onready
var board: Board3D = %Board3D

@onready
var camera_rig: CameraRig = %CameraRig

@onready
var ui: MainMenuUI = %MainMenuUI

func _ready() -> void:
	if ui:
		ui.started.connect(_handle_started)
		ui.quit.connect(_handle_quit)

func _handle_started() -> void:
	camera_rig.is_paused = true

	var tween := create_tween()

	var camera_right := camera_rig.global_basis.x

	tween.tween_property(
		camera_rig,
		"position",
		camera_rig.position + 30 * camera_right,
		0.4
	)

	tween.finished.connect(_load_game)

func _load_game() -> void:
	if game_scene:
		Globals.init_finished = false
		get_tree().change_scene_to_packed(game_scene)

func _handle_quit() -> void:
	get_tree().quit()
