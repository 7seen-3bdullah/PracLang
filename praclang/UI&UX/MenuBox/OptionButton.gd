extends PanelContainer

signal pressed(button: Control)
signal remove_pressed(button: Control)

@onready var button: Button = %Button
@onready var remove_button: Button = %RemoveButton

var removable:= true:
	set(val):
		removable = val
		remove_button.visible = removable

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
	remove_button.pressed.connect(on_remove_button_pressed)

func on_button_pressed() -> void:
	pressed.emit(self)

func on_remove_button_pressed() -> void:
	remove_pressed.emit(self)
