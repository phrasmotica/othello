@tool
class_name OptionCyclerSet extends Resource

@export
var items: Array[String] = []

func get_option_name(idx: int) -> String:
	if idx >= 0 and idx < items.size():
		return items[idx]

	return "???"
