extends Control

signal button_pressed(button: Control)

@onready var box: VBoxContainer = %Box

func add_option_scene_button(packed_scene: PackedScene) -> Control:
	var button = packed_scene.instantiate()
	button.pressed.connect(on_button_pressed)
	box.add_child(button)
	return button

func on_button_pressed(button: Control) -> void:
	button_pressed.emit(button)
