extends Node2D

@onready
var arrow_image: CompressedTexture2D = load("res://assets/images/arrow-cursor-small.png")

@onready
var click_image: CompressedTexture2D = load("res://assets/images/click-cursor.png")

@onready
var hand_image: CompressedTexture2D = load("res://assets/images/hand-cursor.png")

func _ready() -> void:
	Input.set_custom_mouse_cursor(arrow_image, Input.CURSOR_ARROW)
	Input.set_custom_mouse_cursor(click_image, Input.CURSOR_POINTING_HAND)
	Input.set_custom_mouse_cursor(hand_image, Input.CURSOR_DRAG)

func set_pointing() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)

func set_drag() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_DRAG)

func set_default() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)

## Ensures the mouse cursor changes to a pointing cursor when the given control
## is entered by the mouse, even if it's being rendered inside a SubViewport.
## Note that this does not honour any disabled state the control might have.
func set_pointing_cursor_for_control(control: Control) -> void:
	SignalHelper.persist(control.mouse_entered, set_pointing)
	SignalHelper.persist(control.mouse_exited, set_default)
