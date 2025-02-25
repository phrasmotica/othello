extends Node3D

@onready
var main_menu_scene: PackedScene = load("res://scenes/3d/main_menu_3d.tscn")

@onready
var entrance: EntranceOrchestrator = %EntranceOrchestrator

@onready
var game_ui: GameUI = %GameUI

func _ready() -> void:
	if Engine.is_editor_hint():
		return

	if entrance:
		entrance.run()

	if game_ui:
		game_ui.quit_to_main_menu.connect(_handle_quit)

func _handle_quit() -> void:
	if main_menu_scene:
		Globals.init_finished = false
		get_tree().change_scene_to_packed(main_menu_scene)
