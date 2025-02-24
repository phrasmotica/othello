@tool
class_name EnvironmentOptionCyclerSet extends OptionCyclerSet

@export
var environment_options: Array[EnvironmentOption] = []

func get_option_name(idx: int) -> String:
	if idx >= 0 and idx < get_count():
		return environment_options[idx].name

	return "???"

func get_count() -> int:
	return environment_options.size()
