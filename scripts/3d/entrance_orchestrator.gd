class_name EntranceOrchestrator extends Node

@export
var board_entrance_animation: Board3DEntranceAnimation

@export
var score_ui: ScoreUI

signal finished

func _ready() -> void:
	assert(board_entrance_animation != null)
	assert(score_ui != null)

	SignalHelper.persist(board_entrance_animation.finished, score_ui.anim_in)
	SignalHelper.chain(score_ui.starting_animation_finished, finished)

func run() -> void:
	score_ui.hide()

	board_entrance_animation.run()
