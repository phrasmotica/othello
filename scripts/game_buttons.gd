class_name GameButtons extends VBoxContainer

@onready
var restart_button: Button = %RestartButton

@onready
var quit_button: Button = %QuitButton

signal restarted

func _ready() -> void:
	restart_button.pressed.connect(restarted.emit)
	quit_button.pressed.connect(_handle_quit)

func _handle_quit() -> void:
	get_tree().quit()
