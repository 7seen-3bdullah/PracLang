extends PanelContainer

signal pressed(button: Control)

@onready var button: Button = %Button
@onready var code_preview: CodeEdit = %CodePreview

var code: String:
	set(val):
		code = val
		code_preview.set_text(val)
var highlight: SyntaxHighlighter:
	set(val):
		highlight = val
		code_preview.set_syntax_highlighter(val)
var button_group: ButtonGroup:
	set(val):
		button_group = val
		button.button_group = button_group

func _ready() -> void:
	button.pressed.connect(on_button_pressed)

func on_button_pressed() -> void:
	pressed.emit(self)
