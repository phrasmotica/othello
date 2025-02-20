@tool
class_name ScorePanel extends PanelContainer

@export
var score: int:
	set(value):
		score = value

		_refresh()

@export
var is_highlighted := false:
	set(value):
		is_highlighted = value

		_refresh()

@onready
var score_label: Label = %ScoreLabel

@onready
var highlight_control: Control = %Highlight

func _ready() -> void:
	_refresh()

func _refresh() -> void:
	if score_label:
		score_label.text = str(score)

	if highlight_control:
		highlight_control.visible = is_highlighted
