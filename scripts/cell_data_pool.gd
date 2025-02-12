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

func flip(data: BoardCellData) -> BoardCellData:
	if data == white_counter:
		return black_counter

	if data == black_counter:
		return white_counter

	return empty
