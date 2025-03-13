extends FlexibleControl

@onready var message_interface: AIInterface = %MessageInterface

@onready var message_line: LineEdit = %MessageLine
@onready var send_message_button: Button = %SendMessageButton

func _ready() -> void:
	super()
	focus_changed.connect(on_focus_changed)
	send_message_button.pressed.connect(send_message)
	message_interface.result_pushed.connect(on_message_interface_result_pushed)

func on_focus_changed(is_focus: bool) -> void:
	if is_focus:
		await get_tree().process_frame
		GuideServer.push_guides([
			{"Send Message": "[Enter]"},
		])
	else:
		GuideServer.push_guides()



func send_message() -> void:
	var message = message_line.get_text()
	if not message:
		GuideServer.push_message("Enter the message, then send", 1)
		return
	message_interface.send_message(message)
	message_line.clear()
	add_message_box("User", [
		{"text": message},
	])

func on_message_interface_result_pushed(error: int, response: Dictionary) -> void:
	print(response.choices[0].message)




var MESSAGE_BOX = preload("res://Editor/ChatEditor/MessageBox/MessageBox.tscn")
func add_message_box(role: String, message_content: Array) -> void:
	var message_box = MESSAGE_BOX.instantiate()
	












