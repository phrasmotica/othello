extends Node3D

@onready
var main_menu_scene: PackedScene = load("res://scenes/3d/main_menu_3d.tscn")

@onready
var buttons: GameButtons = %GameButtons

func _ready() -> void:
	if buttons:
		buttons.quit_to_main_menu.connect(_handle_quit)

func _handle_quit() -> void:
	if main_menu_scene:
		Globals.init_finished = false
		get_tree().change_scene_to_packed(main_menu_scene)
