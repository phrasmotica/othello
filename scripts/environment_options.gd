@tool
class_name EnvironmentOptions extends Resource

@export
var options: Array[EnvironmentOption] = []

func get_option(idx: int) -> EnvironmentOption:
	if idx < 0 or idx >= options.size():
		return null

	return options[idx]

func get_option_name(idx: int) -> String:
	var option := get_option(idx)
	return option.name if option else ""

func size() -> int:
	return options.size()
