@tool
class_name ScorePanel extends PanelContainer

@export
var score: int:
	set(value):
		score = value

		_refresh()

@onready
var score_label: Label = %ScoreLabel

func _ready() -> void:
	_refresh()

func _refresh() -> void:
	if score_label:
		score_label.text = str(score)
