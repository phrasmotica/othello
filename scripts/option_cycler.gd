## Control for cycling through a list of options.
@tool
class_name OptionCycler extends HBoxContainer

@export
var option_set: OptionCyclerSet

@export
var selected_index := -1:
	set(value):
		var new_index := clampi(value, -1, _get_max_index())
		var is_changed := new_index != selected_index

		selected_index = new_index

		if is_changed:
			selected_index_changed.emit(selected_index)

		_refresh()

@onready
var prev_button: Button = %PrevButton

@onready
var next_button: Button = %NextButton

@onready
var label: Label = %Label

signal selected_index_changed(index: int)

func _ready() -> void:
	if not Engine.is_editor_hint():
		if prev_button:
			SignalHelper.persist(prev_button.pressed, _change_index.bind(-1))

		if next_button:
			SignalHelper.persist(next_button.pressed, _change_index.bind(1))

	# attempt to set the first item. This will trigger a _refresh() call
	selected_index = 0

func _get_max_index() -> int:
	if not option_set:
		return -1

	return option_set.get_count() - 1

func _change_index(amount: int) -> void:
	selected_index += amount

func _refresh() -> void:
	if prev_button:
		prev_button.disabled = selected_index <= 0

	if next_button:
		next_button.disabled = selected_index >= _get_max_index()

	if label:
		var text := option_set.get_option_name(selected_index) if option_set else "???"
		label.text = text
