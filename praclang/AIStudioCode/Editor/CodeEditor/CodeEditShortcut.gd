extends ShortcutNode

@onready var code_editor: Control = $".."
@onready var code_edit: CodeEdit = %CodeEdit
@onready var focus_outliner: FocusOutliner = %FocusOutliner

var font_size: int:
	set(val):
		font_size = clamp(val, 1, 100)
		code_edit.add_theme_font_size_override("font_size", font_size)

func _ready() -> void:
	super()
	font_size = code_edit.get_theme_font_size("font_size")
	create_key_shortcut(CTRL_MASK, KEY_G, code_editor.generate_code)
	create_key_shortcut(CTRL_MASK, KEY_E, code_editor.edit_code)
	create_key_shortcut(CTRL_MASK, KEY_O, code_editor.generate_command)
	create_key_shortcut(CTRL_MASK, KEY_T, code_editor.translate_language)
	create_key_shortcut(CTRL_MASK, KEY_Q, code_editor.imagine_code)
	create_button_shortcut(CTRL_MASK, MOUSE_BUTTON_WHEEL_UP, zoom_in)
	create_button_shortcut(CTRL_MASK, MOUSE_BUTTON_WHEEL_DOWN, zoom_out)


func zoom_in() -> void:
	font_size += 1

func zoom_out() -> void:
	font_size -= 1








