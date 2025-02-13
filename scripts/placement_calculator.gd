@tool
class_name PlacementCalculator extends Node

@export
var board: Board

@export
var turn_tracker: TurnTracker

@export
var ray_calculator: RayCalculator

@export
var game_buttons: GameButtons

var _board_state: BoardStateData

signal computed_plays_available(plays: Dictionary)

func _ready() -> void:
	if board:
		board.state_changed.connect(_handle_state_changed)

	if turn_tracker:
		turn_tracker.starting_colour_changed.connect(_handle_starting_colour_changed)
		turn_tracker.next_colour_changed.connect(_handle_next_colour_changed)

	if not Engine.is_editor_hint():
		if game_buttons:
			game_buttons.restarted.connect(refresh)

func _handle_state_changed(data: BoardStateData) -> void:
	_board_state = data

	refresh()

func _handle_starting_colour_changed(_colour: BoardStateData.CounterType) -> void:
	refresh()

func _handle_next_colour_changed(_colour: BoardStateData.CounterType) -> void:
	refresh()

	var black_play_count := get_plays_for(BoardStateData.CounterType.BLACK)
	var white_play_count := get_plays_for(BoardStateData.CounterType.WHITE)

	computed_plays_available.emit({
		BoardStateData.CounterType.BLACK: black_play_count,
		BoardStateData.CounterType.WHITE: white_play_count,
	})

func refresh() -> void:
	# check place-ability under the assumption that we have all of the cells
	for idx: int in _board_state.cells_data.keys():
		refresh_one(idx)

func refresh_one(idx: int) -> void:
	var can_place := _can_place(idx, _board_state.next_colour)

	if board:
		board.enable_cell(idx, can_place)

func get_plays_for(colour: BoardStateData.CounterType) -> int:
	var count := 0

	for idx: int in _board_state.cells_data.keys():
		if _can_place(idx, colour):
			count += 1

	return count

func _can_place(idx: int, colour: BoardStateData.CounterType) -> bool:
	var cell_data: BoardCellData = _board_state.cells_data[idx]
	if cell_data.has_counter():
		return false

	# cast eight "rays" outwards and check whether the cells that each ray
	# passes through match the regular expressions defined at the top, depending
	# on the colour of this cell. 0 represents a black counter, 1 a white one.
	var rays := ray_calculator.get_rays(idx, colour)
	return rays.size() > 0
