extends Window

@onready var box: VBoxContainer = %Box


func _ready() -> void:
	close_requested.connect(queue_free)


func add_line(placeholder: String, text: String, on_edit = null) -> LineEdit:
	var line = LineEdit.new()
	line.placeholder_text = placeholder
	line.text = text
	if on_edit:
		line.text_changed.connect(on_edit)
	theme_control(line)
	box.add_child(line)
	return line

func add_text(placeholder: String, text: String, on_edit = null) -> TextEdit:
	var text_edit = TextEdit.new()
	text_edit.placeholder_text = placeholder
	text_edit.text = text
	if on_edit:
		text_edit.text_changed.connect(on_edit)
	theme_control(text_edit)
	box.add_child(text_edit)
	return text_edit

func add_button(text: String, on_edit = null) -> Button:
	var button = Button.new()
	button.text = text
	if on_edit:
		button.pressed.connect(on_edit)
	theme_control(button)
	box.add_child(button)
	return button

func add_scene(packed_scene: PackedScene) -> Control:
	var scene = packed_scene.instantiate()
	expand_control(scene)
	box.add_child(scene)
	return scene

func remove_control(index: int) -> void:
	box.get_child(index).queue_free()



func theme_control(control: Control) -> void:
	control.add_theme_stylebox_override("focus", StyleBoxEmpty.new())

func expand_control(control: Control, apply_vertical:= true, apply_horizontal:= true) -> Control:
	if apply_vertical:
		control.size_flags_vertical = Control.SIZE_EXPAND_FILL
	if apply_horizontal:
		control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return control




