extends ShortcutNode

@onready var chat_box: Control = $".."
@onready var message_line: TextEdit = %MessageLine

@export var current_zoom: float = 1.3


func _ready() -> void:
	super()
	create_key_shortcut(NONE_MASK, KEY_ENTER, chat_box.send_message)
	create_key_shortcut(SHIFT_MASK, KEY_ENTER, new_line)
	create_button_shortcut(CTRL_MASK, MOUSE_BUTTON_WHEEL_UP, change_zoom.bind(.1))
	create_button_shortcut(CTRL_MASK, MOUSE_BUTTON_WHEEL_DOWN, change_zoom.bind(-.1))

func new_line() -> void:
	message_line.text += "\n"
	var last_line = message_line.get_line_count() - 1
	var last_column = message_line.get_line(last_line).length()
	message_line.set_caret_line(last_line)
	message_line.set_caret_column(last_column)

func change_zoom(append: float) -> void:
	current_zoom = clamp(current_zoom + append, .5, 3.0)
	update_zoom()

func update_zoom() -> void:
	var zoomable_text_controls = get_tree().get_nodes_in_group("zoomable_text")
	for control: Control in zoomable_text_controls:
		var main_zoom = control.get_meta("main_zoom")
		control.add_theme_font_size_override("font_size", int(main_zoom * current_zoom))
