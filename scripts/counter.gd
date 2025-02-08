@tool
extends Node2D

@export
var is_white := false:
	set(value):
		is_white = value

		_refresh()

@onready
var sprite: Sprite2D = %Sprite2D

var _material: ShaderMaterial

func _ready() -> void:
	_material = sprite.material as ShaderMaterial

	_refresh()

func _refresh() -> void:
	if not _material:
		return

	var colour := Color.WHITE if is_white else Color.BLACK

	_material.set_shader_parameter("colour", colour)
