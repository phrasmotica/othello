@tool
class_name BoardStateData extends Resource

@export
var cells_data := {}:
	set(value):
		if cells_data != value:
			cells_data = value

			emit_changed()

func set_cell(key: int, data: BoardCellData) -> void:
	cells_data[key] = data
