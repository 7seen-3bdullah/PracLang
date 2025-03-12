class_name ShortcutNode extends Node

signal key_shortcut_pressed(key: Array)
signal button_shortcut_pressed(key: Array)

@export var enabled:= true
func set_enabled(val: bool) -> void:
	enabled = val
func get_enabled() -> bool:
	return enabled
@export var gui_control: Control

const NONE_MASK: int = 0
const CTRL_MASK: int = 268435456
const SHIFT_MASK: int = 33554432
const ALT_MASK: int = 67108864

var key_shortcuts: Dictionary[Array, Callable]
var button_shortcuts: Dictionary[Array, Callable]


func _ready() -> void:
	gui_control.gui_input.connect(on_gui_input)


func on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			var key_mask = event.get_modifiers_mask()
			var key = event.button_index
			var result_key = [key_mask, key]
			call_method_from_shortcut(button_shortcuts, result_key)
	elif event is InputEventKey:
		if event.is_pressed():
			var key_mask = event.get_modifiers_mask()
			var key = event.keycode
			var result_key = [key_mask, key]
			call_method_from_shortcut(key_shortcuts, result_key)

func call_method_from_shortcut(shortcut_lib: Dictionary[Array, Callable], key: Array) -> void:
	if key in shortcut_lib:
		var callable = shortcut_lib[key]
		if callable:
			callable.call()
		match shortcut_lib:
			key_shortcuts:
				key_shortcut_pressed.emit(key)
			button_shortcuts:
				button_shortcut_pressed.emit(key)
			_:
				pass


func create_key_shortcut(key_mask: int, key: int, callable: Callable) -> void:
	key_shortcuts[[key_mask, key]] = callable

func create_button_shortcut(key_mask: int, key: int, callable: Callable) -> void:
	button_shortcuts[[key_mask, key]] = callable
