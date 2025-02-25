extends Node2D

@onready
var arrow_image: CompressedTexture2D = load("res://assets/images/arrow-cursor-small.png")

@onready
var click_image: CompressedTexture2D = load("res://assets/images/click-cursor.png")

func _ready() -> void:
	Input.set_custom_mouse_cursor(arrow_image, Input.CURSOR_ARROW)
	Input.set_custom_mouse_cursor(click_image, Input.CURSOR_POINTING_HAND)

func set_pointing() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)

func set_default() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
