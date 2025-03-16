extends Control

signal button_pressed(button: Control)
signal remove_button_pressed(button: Control)

@export var show_title: bool = false
@export var title: String

@onready var box: VBoxContainer = %Box
@onready var title_box: PanelContainer = %TitleBox
@onready var title_label: Label = %Title
@onready var collapse_button: Button = %CollapseButton



var button_group = ButtonGroup.new()


const OPTION_BUTTON = preload("res://UI&UX/MenuBox/OptionButton.tscn")


func _ready() -> void:
	title_box.visible = show_title
	title_label.text = title
	collapse_button.pressed.connect(on_collapse_button_pressed)

func add_option_scene_button(packed_scene: PackedScene = OPTION_BUTTON) -> Control:
	var button = packed_scene.instantiate()
	button.pressed.connect(on_button_pressed)
	button.remove_pressed.connect(on_remove_button_pressed)
	box.add_child(button)
	button.button_group = button_group
	return button

func on_button_pressed(button: Control) -> void:
	button_pressed.emit(button)
func on_remove_button_pressed(button: Control) -> void:
	remove_button_pressed.emit(button)

func clear_buttons() -> void:
	for i in box.get_children():
		i.queue_free()

func on_collapse_button_pressed() -> void:
	box.visible = not box.visible
	collapse_button.text = "Collapse" if box.visible else "Expand"








