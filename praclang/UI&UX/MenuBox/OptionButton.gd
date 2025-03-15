extends PanelContainer

signal pressed(button: Control)

@onready var button: Button = %Button

var text: String:
	set(val):
		text = val
		button.text = val

var button_group: ButtonGroup:
	set(val):
		button_group = val
		button.button_group = button_group

func _ready() -> void:
	button.pressed.connect(on_button_pressed)

func on_button_pressed() -> void:
	pressed.emit(self)
