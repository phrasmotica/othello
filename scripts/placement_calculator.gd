@tool
class_name PlacementCalculator extends Node

class AvailablePlays extends Resource:
	@export
	var plays: Array[int] = []

	func can_play() -> bool:
		return plays.size() > 0

@export
var turn_tracker: TurnTracker

@export
var ray_calculator: RayCalculator

var _board_state: BoardStateData

signal refreshed_cell(idx: int, can_place: bool)

func connect_to_board(board: Board) -> void:
	board.state_changed.connect(_handle_state_changed)

	refreshed_cell.connect(board.enable_cell)

func connect_to_board_3d(board_3d: Board3D) -> void:
	board_3d.state_changed.connect(_handle_state_changed)

	refreshed_cell.connect(board_3d.enable_cell)

func _handle_state_changed(data: BoardStateData) -> void:
	_board_state = data

	# MEDIUM: only refresh if this came from a counter being placed,
	# or from an entire set of flips completing
	refresh_for(_board_state.next_colour)

func compute_plays() -> Dictionary[BoardStateData.CounterType, AvailablePlays]:
	var black_plays := _get_plays_for(BoardStateData.CounterType.BLACK)
	var white_plays := _get_plays_for(BoardStateData.CounterType.WHITE)

	return {
		BoardStateData.CounterType.BLACK: black_plays,
		BoardStateData.CounterType.WHITE: white_plays,
	}

func refresh_for(colour: BoardStateData.CounterType) -> void:
	# check place-ability under the assumption that we have all of the cells
	for idx: int in _board_state.cells_data.keys():
		_refresh_one(colour, idx)

func _refresh_one(colour: BoardStateData.CounterType, idx: int) -> void:
	var can_place := _can_place(idx, colour)

	refreshed_cell.emit(idx, can_place)

func _get_plays_for(colour: BoardStateData.CounterType) -> AvailablePlays:
	var plays: Array[int] = []

	for idx: int in _board_state.cells_data.keys():
		if _can_place(idx, colour):
			plays.append(idx)

	var result := AvailablePlays.new()
	result.plays = plays

	return result

func _can_place(idx: int, colour: BoardStateData.CounterType) -> bool:
	var cell_data: BoardCellData = _board_state.cells_data[idx]
	if cell_data.has_counter():
		return false

	var rays := ray_calculator.get_rays(idx, colour)
	return rays.size() > 0
