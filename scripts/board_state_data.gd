@tool
class_name BoardStateData extends Resource

enum CounterType { BLACK, WHITE }

const MIN_WIDTH := 6
const MIN_HEIGHT := 6
const MAX_WIDTH := 8
const MAX_HEIGHT := 8

@export
var board_size: Vector2i = Vector2i(MAX_WIDTH, MAX_HEIGHT):
	set(value):
		value.x = clampi(value.x, MIN_WIDTH, MAX_WIDTH)
		value.y = clampi(value.y, MIN_HEIGHT, MAX_HEIGHT)

		if board_size != value:
			board_size = value

			emit_changed()

@export
var cells_data := {}:
	set(value):
		if cells_data != value:
			cells_data = value

			emit_changed()

@export
var next_colour := CounterType.BLACK:
	set(value):
		if next_colour != value:
			next_colour = value

			emit_changed()

func get_cell(key: int) -> BoardCellData:
	if not cells_data.has(key):
		return null

	return cells_data[key] as BoardCellData

func set_cell(key: int, data: BoardCellData) -> void:
	cells_data[key] = data

func get_counter_count() -> int:
	return cells_data.values().filter(
		func(d: BoardCellData) -> bool:
			return d.has_counter()
	).size()

func get_remaining_cell_count() -> int:
	return board_size.x * board_size.y - get_counter_count()
