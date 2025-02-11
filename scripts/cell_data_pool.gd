@tool
class_name CellDataPool extends Node

@export
var next_colour: BoardCell.CounterType

@export
var black_counter: BoardCellData

@export
var white_counter: BoardCellData

@export
var empty: BoardCellData

func get_next() -> BoardCellData:
	if next_colour == BoardCell.CounterType.BLACK:
		return black_counter

	return white_counter

func get_default_counter(size: Vector2i, x_pos: int, y_pos: int) -> BoardCellData:
	var half_x := int(float(size.x) / 2)
	var half_y := int(float(size.y) / 2)

	var starts_filled := [half_x, half_x - 1].has(x_pos) and [half_y, half_y - 1].has(y_pos)
	if starts_filled:
		if (x_pos + y_pos) % 2 != 0:
			return white_counter

		return black_counter

	return empty

func flip(data: BoardCellData) -> BoardCellData:
	if data == white_counter:
		return black_counter

	if data == black_counter:
		return white_counter

	return empty
