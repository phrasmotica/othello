@tool
class_name EnvironmentOptionCyclerSet extends OptionCyclerSet

@export
var environment_options: EnvironmentOptions

func get_option_name(idx: int) -> String:
	if idx >= 0 and idx < get_count():
		return environment_options.get_option_name(idx)

	return "???"

func get_count() -> int:
	return environment_options.size()
