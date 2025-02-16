extends Node3D

@onready
var game_scene: PackedScene = load("res://scenes/3d/game_3d.tscn")

@onready
var ui: MainMenuUI = %MainMenuUI

func _ready() -> void:
	if ui:
		ui.started.connect(_handle_started)
		ui.quit.connect(_handle_quit)

func _handle_started() -> void:
	if game_scene:
		Globals.init_finished = false
		get_tree().change_scene_to_packed(game_scene)

func _handle_quit() -> void:
	get_tree().quit()
