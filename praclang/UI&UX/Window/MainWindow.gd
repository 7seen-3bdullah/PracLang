extends Window

@onready var box: VBoxContainer = %Box

var previous_text: String = ""

func _ready() -> void:
	close_requested.connect(queue_free)


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ENTER:
			return
		await get_tree().process_frame
		var focus_owner = get_viewport().gui_get_focus_owner()
		var current_text = focus_owner.text if (focus_owner and focus_owner is LineEdit) else ""
		if current_text != previous_text:
			previous_text = current_text
			Sounds.Typing_Sound()

func add_label(text: String, font_color:= Color.WHITE) -> Label:
	var label = Label.new()
	label.set_text(text)
	label.set_autowrap_mode(TextServer.AUTOWRAP_WORD)
	label.add_theme_color_override("font_color", font_color)
	box.add_child(label)
	return label

func add_line(placeholder: String, text: String, on_edit = null) -> LineEdit:
	var line = LineEdit.new()
	line.placeholder_text = placeholder
	line.text = text
	if on_edit:
		line.text_changed.connect(on_edit)
	theme_control(line)
	box.add_child(line)
	return line

func add_text(placeholder: String, text: String, on_edit = null) -> CopiedCodeEdit:
	var text_edit = CopiedCodeEdit.new()
	text_edit.placeholder_text = placeholder
	text_edit.text = text
	
	if on_edit:
		text_edit.text_changed.connect(on_edit)
	theme_control(text_edit)
	box.add_child(text_edit)
	return text_edit

func add_button(text: String, on_pressed = null) -> Button:
	var button = Button.new()
	button.text = text
	if on_pressed:
		button.pressed.connect(on_pressed)
	theme_control(button)
	box.add_child(button)
	return button

func add_options_button(options: Array[String], on_item_selected = null) -> OptionButton:
	var button = OptionButton.new()
	for option in options:
		button.add_item(option)
	
	# تشغيل الصوت عند الضغط على الزر لفتح القائمة
	button.pressed.connect(func(): Sounds.Click_Sound(1, -10))
	
	# تشغيل الصوت عند اختيار عنصر من القائمة
	button.item_selected.connect(func(_idx): Sounds.Click_Sound(1, -10))
	
	if on_item_selected:
		button.item_selected.connect(on_item_selected)
	
	theme_control(button)
	box.add_child(button)
	return button

func add_scene(packed_scene: PackedScene) -> Control:
	var scene = packed_scene.instantiate()
	expand_control(scene)
	box.add_child(scene)
	return scene

func add_name_split(control: Control, name: String, enable_dragging:= false) -> SplitContainer:
	var split = SplitContainer.new()
	split.dragging_enabled = enable_dragging
	box.add_child(split)
	var label = add_label(name, Color.GRAY)
	label.reparent(split); label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	control.reparent(split); control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return split



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
