extends PanelContainer

signal pressed(button: Control)
signal remove_pressed(button: Control)

@onready var button: Button = %Button
@onready var remove_button: Button = %RemoveButton

var button_pressed: bool:
	set(val):
		button_pressed = val
		button.button_pressed = val

var removable:= true:
	set(val):
		removable = val
		remove_button.visible = removable

var text: String:
	set(val):
		text = val
		button.text = val

var button_group: ButtonGroup:
	set(val):
		button_group = val
		button.button_group = button_group

func _ready() -> void:
	button.pressed.connect(on_button_pressed)
	remove_button.pressed.connect(on_remove_button_pressed)
	mouse_entered.connect(remove_button.show)
	mouse_exited.connect(remove_button.hide)
	button.mouse_entered.connect(_mouse_entered)
	remove_button.hide()


func on_button_pressed() -> void:
	pressed.emit(self)
	
	Sounds.Click_Sound(1,-5)

func on_remove_button_pressed() -> void:
	remove_pressed.emit(self)
	
	Sounds.Click_Sound(1,-5)


func _mouse_entered() -> void:
	#صوت ضغط الزر
	Sounds.Click_Sound(2.3,-10)
