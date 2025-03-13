extends FlexibleControl

@onready var shortcut_node: Node = %ShortcutNode
@onready var message_interface: AIInterface = %MessageInterface
@onready var tween_plus: TweenPlus = %TweenPlus

@onready var message_line: LineEdit = %MessageLine
@onready var send_message_button: Button = %SendMessageButton
@onready var processing_control: ProcessingControl = %ProcessingControl
@onready var messages_box: VBoxContainer = %MessagesBox
@onready var scroll_container: ScrollContainer = %ScrollContainer

var user_current_message: Control


func _ready() -> void:
	super()
	
	focus_changed.connect(on_focus_changed)
	
	send_message_button.pressed.connect(send_message)
	messages_box.child_entered_tree.connect(on_child_entered_tree)
	
	message_interface.result_pushed.connect(on_message_interface_result_pushed)
	message_interface.error_pushed.connect(on_message_interface_error_pushed)
	


# -------------------------------


func on_focus_changed(is_focus: bool) -> void:
	if is_focus:
		await get_tree().process_frame
		GuideServer.push_guides([
			{"Send Message": "[Enter]"},
		])
	else:
		GuideServer.push_guides()

func on_child_entered_tree(node: Node) -> void:
	await get_tree().process_frame
	var max_scroll_value = scroll_container.get_v_scroll_bar().max_value
	scroll_container.set_deferred("scroll_vertical", max_scroll_value)


# -------------------------------


func send_message() -> void:
	var message = message_line.get_text()
	if not message:
		GuideServer.push_message("Enter the message, then send", 1)
		return
	message_interface.send_message(message)
	message_line.clear()
	add_message_box("User", [{"text": message}])
	processing_control.show()


# -------------------------------


func on_message_interface_result_pushed(error: int, response: Dictionary) -> void:
	var message = response.choices[0].message.content
	add_message_box("AI", [{"text": message}])
	processing_control.hide()

func on_message_interface_error_pushed() -> void:
	pass


# -------------------------------


var MESSAGE_BOX = preload("res://Editor/ChatEditor/MessageBox/MessageBox.tscn")
const AI_MESSAGE_STYLE = preload("res://UI&UX/Style/AIMessageStyle.tres")
const USER_MESSAGE_STYLE = preload("res://UI&UX/Style/UserMessageStyle.tres")

func add_message_box(role: String, messages_content: Array) -> void:
	var message_box = MESSAGE_BOX.instantiate()
	messages_box.add_child(message_box)
	match role:
		"User":
			message_box.setup(USER_MESSAGE_STYLE, Color("3b4873"), role, messages_content)
			user_current_message = message_box
		"AI":
			message_box.setup(AI_MESSAGE_STYLE, Color.GRAY, role, messages_content)
	messages_box.move_child(processing_control, messages_box.get_child_count()-1)









