extends Control

signal button_pressed(button: Control)

@onready var box: VBoxContainer = %Box

const OPTION_BUTTON = preload("res://UI&UX/MenuBox/OptionButton.tscn")

func add_option_scene_button(packed_scene: PackedScene = OPTION_BUTTON) -> Control:
	var button = packed_scene.instantiate()
	button.pressed.connect(on_button_pressed)
	box.add_child(button)
	return button

func on_button_pressed(button: Control) -> void:
	button_pressed.emit(button)

func clear_buttons() -> void:
	for i in box.get_children():
		i.queue_free()


