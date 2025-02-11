@tool
class_name BoardStateData extends Resource

@export
var cells_data: Dictionary:
	set(value):
		if cells_data != value:
			cells_data = value

			emit_changed()
