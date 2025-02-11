@tool
class_name Board extends Node2D

const MIN_WIDTH := 6
const MIN_HEIGHT := 6
const MAX_WIDTH := 8
const MAX_HEIGHT := 8

@export
var size: Vector2i = Vector2i(MAX_WIDTH, MAX_HEIGHT):
	set(value):
		value.x = clampi(value.x, MIN_WIDTH, MAX_WIDTH)
		value.y = clampi(value.y, MIN_HEIGHT, MAX_HEIGHT)

		if size != value:
			size = value

			_refresh()

@export
var starting_colour := BoardCell.CounterType.BLACK:
	set(value):
		if starting_colour != value:
			starting_colour = value

			if board_creator:
				board_creator.set_next_colour(starting_colour)

@export_group("External Dependencies")

@export
var score_ui: ScoreUI

@export
var game_buttons: GameButtons

@export
var debug_handler: DebugHandler

@onready
var board_creator: BoardCreator = %BoardCreator

@onready
var board_state: BoardState = %BoardState

@onready
var placement_calculator: PlacementCalculator = %PlacementCalculator

var _next_turn_colour := starting_colour

signal score_changed(black_score: int, white_score: int)
signal game_ended

func _ready() -> void:
	if not Engine.is_editor_hint():
		board_state.score_changed.connect(score_changed.emit)
		board_creator.turn_ended.connect(_handle_turn_ended)

		if score_ui:
			score_ui.ready.connect(_handle_score_ui_ready)

		if game_buttons:
			game_buttons.restarted.connect(_handle_restarted)

		if debug_handler:
			debug_handler.play_random.connect(_handle_play_random)

	_refresh()

func _refresh() -> void:
	if board_creator:
		board_creator.render_board(size, self)

func _handle_score_ui_ready() -> void:
	board_state.update_score()

func _handle_restarted() -> void:
	if board_creator:
		board_creator.reset_board()

func _handle_play_random() -> void:
	if board_creator:
		board_creator.play_random()

func _go_to_next_turn(last_turn_passed: bool) -> void:
	_next_turn_colour = ((_next_turn_colour + 1) % 2) as BoardCell.CounterType

	print("Turn ended, now it's %d turn" % _next_turn_colour)

	board_creator.set_next_colour(_next_turn_colour)

	var available_play_count := placement_calculator.get_plays()

	if available_play_count <= 0:
		print("No plays available for %d" % _next_turn_colour)

		if last_turn_passed:
			print("Game ended!")
			game_ended.emit()
		else:
			# MEDIUM: if there are no possible plays, force the current player to click a
			# "continue" button
			print("Skipping turn")
			_go_to_next_turn(true)

func _handle_turn_ended() -> void:
	_go_to_next_turn(false)
