class_name CopiedCodeEdit extends CodeEdit

@export var copy_text: String = ""
@export var copied_text: String = ""
@export var copy_icon: Texture2D = preload("res://UI&UX/Icon/pngaaa.com-5101346.png")
@export var copied_icon: Texture2D = preload("res://UI&UX/Icon/pngaaa.com-5101346.png")
@export var copy_button_size:= Vector2.ONE * 38

var copy_button:= Button.new()


func _ready() -> void:
	copy_button.set_size(copy_button_size)
	copy_button.set_text(copy_text)
	copy_button.icon = copy_icon
	copy_button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	copy_button.expand_icon = true
	copy_button.set_mouse_filter(Control.MOUSE_FILTER_PASS)
	copy_button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	copy_button.pressed.connect(on_copy_button_pressed)
	update()
	copy_button.hide()
	add_child(copy_button)
	
	resized.connect(update)
	copy_button.resized.connect(update)
	mouse_entered.connect(on_mouse_entered)
	mouse_exited.connect(on_mouse_exited)

func update() -> void:
	copy_button.set_position(Vector2(size.x - copy_button.size.x, .0))

func on_mouse_entered() -> void:
	copy_button.show()

func on_mouse_exited() -> void:
	copy_button.hide()

func on_copy_button_pressed() -> void:
	Sounds.Error_sound("cope", 2.2)
	
	DisplayServer.clipboard_set(get_text())
	copy_button.set_text(copied_text)
	copy_button.icon = copied_icon
	await get_tree().create_timer(.5).timeout
	copy_button.set_text(copy_text)
	copy_button.icon = copy_icon
