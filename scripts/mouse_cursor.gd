extends Node2D

@onready
var arrow_image: CompressedTexture2D = load("res://assets/images/arrow-cursor.png")

@onready
var click_image: CompressedTexture2D = load("res://assets/images/click.png")

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func _process(_delta: float) -> void:
	position = get_viewport().get_mouse_position()
