class_name SettingsMenuUI extends PanelContainer

@onready
var preview_flips_check_box: CheckBox = %PreviewFlipsCheckBox

@onready
var environment_cycler: OptionCycler = %EnvironmentOptionCycler

@onready
var close_button: Button = %CloseButton

signal preview_flips_check_box_toggled(toggled_on: bool)
signal environment_cycler_selected_index_changed(index: int)
signal close_button_pressed

func _ready() -> void:
	if preview_flips_check_box:
		SignalHelper.chain(
			preview_flips_check_box.toggled,
			preview_flips_check_box_toggled
		)

	if environment_cycler:
		SignalHelper.chain(
			environment_cycler.selected_index_changed,
			environment_cycler_selected_index_changed
		)

	if close_button:
		SignalHelper.chain(
			close_button.pressed,
			close_button_pressed
		)
