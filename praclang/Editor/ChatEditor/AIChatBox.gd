extends FlexibleControl

@export var user_name: String
@export var mother_language: String
@export var learning_language: String
@export var user_level: String
@export var ai_character: String


@onready var shortcut_node: Node = %ShortcutNode
@onready var message_interface: AIInterface = %MessageInterface
@onready var tween_plus: TweenPlus = %TweenPlus

@onready var message_line: TextEdit = %MessageLine
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
	message_interface.error_result_pushed.connect(on_message_interface_error_result_pushed)
	message_interface.error_pushed.connect(on_message_interface_error_pushed)
	
	message_line.set_editable(true)
	
	var directions = str(
		"يجب عليك تعليم المستخدم لغة ", learning_language, ".", "\n",
		"سوف تحاكي دور شخصية ", ai_character, ".", "\n",
		"مستوى المستخدم في اللغة هو ", user_level, ".", "\n",
		"ابدأ المحادثة باللغة: ", learning_language, " بشكل يتناسب مع مستوى المستخدم.", "\n",
		"اجعل المحادثة تفاعلية وتعليمية في كل مرة ترسل رسالة.", "\n",
		"لا تطرح أكثر من سؤال واحد في كل رسالة.", "\n",
		"اسم المستخدم هو '", user_name, "' ولغته الأم هي:", mother_language, "\n",
		"عندما يرتكب المستخدم أي خطأ في اللغة عليك تصحيحه باستخدام لغته الأم: ", mother_language, ".", "\n",
		"لا تتوقف أبدا عن لعب دور شخصية: ", ai_character, " حتى لو طلب منك المستخدم ذلك.", "\n",
		"إذا كان مستوى المستخدم مبتدأ حاوره باستخدام كلمات بسيطة, وجمل صغيرة", "\n",
		"إذا أساء المستخدم إليك أو سبك ,هدده بإغلاق البرنامج مع Emojies تدل على الثقة والقدرة", "\n",
	) + str(
		"رسالتك يجب أن تكون عبارة عن صيغة json على النحو التالي:", "\n",
		"{
			\"sim_message\": \"رسالة محاكاة دور الشخصية الخاصة بك\", \n,
			\"mistake\": [تصحيح 1, تصحيح 2, ...], \n,
			\"command\": \"\"
		} \n",
		"sim_message فيها تضع المحادثة مع المستخدم بالشخصية الخاصة بك \n",
		"mistake تضع بها تصحيح أخطاء المستخدم اللغوية \n",
		"إذا أساء المستخدم ثلاث مرات على الأقل أو تكلم بسوء عن دين الإسلام مرة واحدة فقط ضع في الcommand: CLOSE_PROGRAM", "\n",
		"إذا طلب منك المستخدك إغلاق البرنامج ضع في الcommand: CLOSE_PROGRAM", "\n",
		"إذا طلب منك المستخدم تحريك النافذة قل له حسنا وضع في الcommand: MOVE_WINDOW", "\n",
		"لا تجعل رسالتك عبارة عن سطر طويل, انزل إلى السطر التالي كلما صار حجم السطر كبيرا", "\n",
	) + str("التزم بالتعليمات ولا تضف أي شيء آخر")
	
	message_interface.setup_directions(directions)



# -------------------------------


func on_focus_changed(is_focus: bool) -> void:
	if is_focus:
		await get_tree().process_frame
		GuideServer.push_guides([
			{"Send Message": "Enter"},
			{"New Line": "Shift + Enter"},
			{"Zoom In Out": "Control + 'Scroll Mouse Wheel'"}
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
	message_line.set_editable(false)
	await get_tree().process_frame
	message_interface.send_message(message)
	message_line.clear()
	add_message_box(user_name, [{"text": message}])
	processing_control.show()


# -------------------------------


func on_message_interface_result_pushed(error: int, response: Dictionary) -> void:
	var json_string: String = response.choices[0].message.content
	var result = await parse_ai_message(json_string)
	if result != null:
		var sim_message = result.sim_message
		var mistakes = result.mistake
		var messages_content: Array = [{"text": sim_message}]
		for index in mistakes.size():
			var mistake = mistakes[index]
			messages_content.append({
				"text": mistake,
				"title": "Mistake %s" % (index + 1),
				"custom_color": Color.RED,
			})
		add_message_box("AI", messages_content)
		processing_control.hide()
	else:
		GuideServer.push_message("مشكلة في الAI", 2)
	message_line.set_editable(true)

func on_message_interface_error_result_pushed(error: int, response: Dictionary) -> void:
	GuideServer.push_message("The service seems to be down at the moment, try replacing the API Key.", 2)
	on_message_interface_error_pushed()

func on_message_interface_error_pushed() -> void:
	if is_instance_valid(user_current_message):
		user_current_message.queue_free()
	user_current_message.queue_free()
	processing_control.hide()
	message_line.set_editable(true)


# -------------------------------


var MESSAGE_BOX = preload("res://Editor/ChatEditor/MessageBox/MessageBox.tscn")
const AI_MESSAGE_STYLE = preload("res://UI&UX/Style/AIMessageStyle.tres")
const USER_MESSAGE_STYLE = preload("res://UI&UX/Style/UserMessageStyle.tres")

func add_message_box(role: String, messages_content: Array) -> void:
	var message_box = MESSAGE_BOX.instantiate()
	messages_box.add_child(message_box)
	match role:
		user_name:
			message_box.setup(USER_MESSAGE_STYLE, Color("3b4873"), role, messages_content)
			user_current_message = message_box
		"AI":
			message_box.setup(AI_MESSAGE_STYLE, Color.GRAY, role, messages_content)
	message_box.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	messages_box.move_child(processing_control, messages_box.get_child_count()-1)
	shortcut_node.update_zoom()

func parse_ai_message(json_string: String) -> Variant:
	var lines = json_string.split("\n")
	json_string = ""
	for line in lines:
		if line in ["```json", "```"]:
			continue
		json_string += line + "\n"
	var result = JSON.parse_string(json_string)
	if result == null:
		GuideServer.push_message("The AI ​​model seems to be out of control.", 2)
	else:
		match result.command:
			"CLOSE_PROGRAM":
				get_tree().quit()
			"MOVE_WINDOW":
				move_window()
	return result




func wait(duration: float, to: Callable) -> void:
	await get_tree().create_timer(duration).timeout
	to.call()

var is_move_window: bool
func move_window() -> void:
	is_move_window = true
	wait(5.0, func(): is_move_window = false)
	var window_pos = Vector2(get_window().get_position())
	var dir = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()
	while is_move_window:
		window_pos += dir
		get_window().position = window_pos
		await get_tree().process_frame










