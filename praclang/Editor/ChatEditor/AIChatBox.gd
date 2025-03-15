extends FlexibleControl

@export var languages: Array[String]
@export var levels: Array[String]
@export var ai_characters: Array[String] = [
	# Academic & Educational
	"Patient Teacher",
	"Specialized Professor",
	"Personal Trainer",
	"Storytelling Historian",
	"Curious Scientist",
	# Technical & Programming
	"Software Engineer",
	"AI Expert",
	"Robotics Programmer",
	"Genius Inventor",
	"Cybersecurity Specialist",
	# Literary & Artistic
	"Creative Writer",
	"Romantic Poet",
	"Mysterious Novelist",
	"Visual Artist",
	"Film Critic",
	# Entertainment & Fictional
	"Wise Storyteller",
	"Witty Genie",
	"Adventurous Pirate",
	"Sharp Detective",
	"Futuristic Robot",
	# Historical & Cultural
	"Ancient Philosopher",
	"Brave Military Leader",
	"Bold Explorer",
	"Wise King",
	"Pioneer Inventor",
	# Scientific & Experimental
	"Theoretical Physicist",
	"Mad Chemist",
	"Space Scientist",
	"Friendly Doctor",
	"Curious Biologist",
	# Business & Entrepreneurial
	"Ambitious Businessman",
	"Smart Investor",
	"Marketing Expert",
	"Financial Analyst",
	"Startup Founder",
	# Sports & Health
	"Athletic Coach",
	"Psychologist",
	"Nutritionist",
	"Chess Strategist",
	"Mountain Climber",
	# Humorous & Satirical
	"Witty Comedian",
	"Sharp Satirist",
	"Beloved Clown",
	"Clever Trickster",
	"Joke Maker",
	# Futuristic & Sci-Fi
	"Advanced AI",
	"Interactive Android",
	"Alien Researcher",
	"Cyber Consultant",
	"Future Oracle",
	# Islamic Studies & Spiritual
	"Islamic Scholar",
	"Hadith Narrator",
	"Fiqh Expert",
	"Ethical Imam"
]
@export var current_session: SessionsRes

var user_name: String
var mother_language: String
var learning_language: String
var user_level: String
var ai_character: String

@onready var shortcut_node: Node = %ShortcutNode
@onready var message_interface: AIInterface = %MessageInterface
@onready var tween_plus: TweenPlus = %TweenPlus

@onready var new_session_button: Button = %NewSessionButton
@onready var message_line: TextEdit = %MessageLine
@onready var send_message_button: Button = %SendMessageButton
@onready var processing_control: ProcessingControl = %ProcessingControl
@onready var messages_box: VBoxContainer = %MessagesBox
@onready var no_session_message: Label = %NoSessionMessage
@onready var scroll_container: ScrollContainer = %ScrollContainer

@onready var side_box: VBoxContainer = %SideBox
@onready var sessions_box: Control = %SessionsBox

@onready var choices_box: HBoxContainer = %ChoicesBox
@onready var show_session_info_button: Button = %ShowSessionInfoButton



var mistakes_menues: Dictionary[String, Control]
var user_current_message: Control

const MENU_BOX = preload("res://UI&UX/MenuBox/MenuBox.tscn")



func _ready() -> void:
	super()
	
	focus_changed.connect(on_focus_changed)
	
	new_session_button.pressed.connect(create_new_session)
	send_message_button.pressed.connect(send_message)
	messages_box.child_entered_tree.connect(on_child_entered_tree)
	sessions_box.button_pressed.connect(on_session_button_pressed)
	
	message_interface.result_pushed.connect(on_message_interface_result_pushed)
	message_interface.error_result_pushed.connect(on_message_interface_error_result_pushed)
	message_interface.error_pushed.connect(on_message_interface_error_pushed)
	
	show_session_info_button.pressed.connect(on_show_session_info_button_pressed)
	
	message_line.set_editable(false)
	choices_box.hide()
	
	for language in languages:
		var mistakes_menu = MENU_BOX.instantiate()
		mistakes_menu.show_title = true
		mistakes_menu.title = str(language, " Mistakes")
		mistakes_menu.hide()
		side_box.add_child(mistakes_menu)
		mistakes_menu.button_pressed.connect(on_mistake_button_pressed)
		mistakes_menues[language] = mistakes_menu
		SaveServer.make_mistake_dir_absolute(language)
		load_mistakes(language)
	
	load_session_buttons()




# -------------------------------


func on_focus_changed(is_focus: bool) -> void:
	if is_focus:
		await get_tree().process_frame
		GuideServer.push_guides([
			{"New Session": "Control + A"},
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

func on_session_button_pressed(button: Control) -> void:
	var session_path = button.get_meta("session_path")
	var session_res = SaveServer.load_session(session_path)
	load_session(session_res)

func on_mistake_button_pressed(button: Control) -> void:
	var mistake = button.text
	var window = WindowManager.popup_window(get_owner(), Vector2(400, 300))
	var mistake_edit = window.expand_control(window.add_text("", mistake))
	mistake_edit.set_editable(false)


func on_show_session_info_button_pressed() -> void:
	var info = str(get_session_data()).replace(",", ",\n\n")
	var window = WindowManager.popup_window(get_owner(), Vector2i(300, 300))
	var info_edit = window.expand_control(window.add_text("", info))
	info_edit.set_editable(false)
	window.unresizable = true


# -------------------------------


func on_message_interface_result_pushed(error: int, response: Dictionary) -> void:
	var content: String = response.choices[0].message.content
	var result = await parse_ai_message(content)
	if result != null:
		var messages_content = get_message_content_from_ai_parsed_message(result)
		add_message_box("AI", messages_content)
		processing_control.hide()
		await get_tree().process_frame
		current_session = SaveServer.save_session(
			message_interface.chat_history,
			get_session_data(),
			current_session.resource_path
		)
		SaveServer.save_mistakes(result.mistake, learning_language)
		load_mistakes()
	else:
		GuideServer.push_message("مشكلة في الAI", 2)
		processing_control.hide()
	message_line.set_editable(true)
	processing_control.hide()


func on_message_interface_error_result_pushed(error: int, response: Dictionary) -> void:
	GuideServer.push_message("The service seems to be down at the moment, try replacing the API Key.", 2)
	on_message_interface_error_pushed()

func on_message_interface_error_pushed() -> void:
	if is_instance_valid(user_current_message):
		user_current_message.queue_free()
	message_line.set_editable(true)
	processing_control.hide()


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

func get_message_content_from_ai_parsed_message(parsed_message: Dictionary) -> Array:
	var sim_message = parsed_message.sim_message
	var mistakes = parsed_message.mistake
	var messages_content: Array = [{"text": sim_message}]
	for index in mistakes.size():
		var mistake = mistakes[index]
		messages_content.append({
			"text": mistake,
			"title": "Mistake %s" % (index + 1),
			"custom_color": Color.RED,
		})
	return messages_content


# -------------------------------

func create_new_session() -> void:
	
	if processing_control.visible:
		GuideServer.push_message("الرجاء الإنتظار حتى إنتهاء الطلب الحالي.", 1)
		return
	
	var window = WindowManager.popup_window(get_owner(), Vector2(400, 210))
	var user_name_line = window.add_line("your Name", user_name)
	var mother_lang_button = window.add_options_button(languages)
	var learning_lang_button = window.add_options_button(languages)
	var user_level_button = window.add_options_button(levels)
	var ai_character_button = window.add_options_button(ai_characters)
	window.add_button("Accept", func():
		
		if not user_name_line.text:
			GuideServer.push_message("You must provide your name.", 1)
			return
		user_name = user_name_line.text
		mother_language = mother_lang_button.get_item_text(mother_lang_button.get_selected_id())
		learning_language = learning_lang_button.get_item_text(learning_lang_button.get_selected_id())
		user_level = user_level_button.get_item_text(user_level_button.get_selected_id())
		ai_character = ai_character_button.get_item_text(ai_character_button.get_selected_id())
		
		message_line.set_editable(false)
		processing_control.show()
		no_session_message.hide()
		
		var directions = str(
			"يجب عليك تعليم المستخدم لغة ", learning_language, ".", "\n",
			"سوف تحاكي دور شخصية ", ai_character, ".", "\n",
			"المحاكاة يجب أن تكون واقعية, يجب أن تكون في زمان تلك الشخصية, بمعنى أنه إذا كانت الشخصية قديمة فلا يجب أن تعرف الأمور التي تتعلق بالتكنولوجيا ...", "\n",
			"ولا يجب لك أن تتدخل في أمور مختلفة عن تعليم اللغة المطلوبة منك, لا تفتح نقاشات أخرى, وإذا أراد المستخدم ذاك أخبره أن عملك هو تعليم اللغة", "\n",
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
		
		message_interface.chat_history.clear()
		remove_session_messages()
		message_interface.setup_directions(directions)
		current_session = SaveServer.save_session(message_interface.chat_history, get_session_data())
		load_session_buttons()
		choices_box.show()
		window.close_requested.emit()
	)
	user_name_line.text_changed.connect(
		func(new_text: String):
			var regex = RegEx.new()
			regex.compile("^[\\p{L}\\s]+$")
			if not regex.search(new_text):
				user_name_line.text = ""
	)
	learning_lang_button.select(1)
	window.unresizable = true


func load_session_buttons() -> void:
	var sessions = SaveServer.load_sessions()
	sessions_box.clear_buttons()
	for session in SaveServer.load_sessions():
		var button = sessions_box.add_option_scene_button()
		var session_path = session.resource_path
		button.text = session_path.get_file().get_basename()
		button.set_meta("session_path", session_path)

func load_session(session_res: SessionsRes) -> void:
	
	if processing_control.visible:
		GuideServer.push_message("الرجاء الإنتظار حتى إنتهاء الطلب الحالي.", 1)
		return
	
	message_line.set_editable(true)
	no_session_message.hide()
	remove_session_messages()
	
	message_interface.chat_history = session_res.session_history
	user_name = session_res.user_name
	mother_language = session_res.mother_language
	learning_language = session_res.learning_language
	user_level = session_res.user_level
	ai_character = session_res.ai_character
	current_session = session_res
	
	for history_chunk in message_interface.chat_history:
		var role = history_chunk.role
		var content = history_chunk.content
		match role:
			"system":
				pass
			"assistant":
				var message_result = parse_ai_message(content)
				var messages_content = get_message_content_from_ai_parsed_message(message_result)
				add_message_box("AI", messages_content)
			_:
				add_message_box(user_name, [{"text": content[0].text}])
	choices_box.show()

func get_session_data() -> Dictionary:
	return {
		"user_name": user_name,
		"mother_language": mother_language,
		"learning_language": learning_language,
		"user_level": user_level,
		"ai_character": ai_character
	}


func remove_session_messages() -> void:
	for i in messages_box.get_children():
		if i == processing_control:
			continue
		i.queue_free()

const MISTAKE_BUTTON = preload("res://UI&UX/MenuBox/MistakeButton.tscn")

func load_mistakes(language:= learning_language) -> void:
	var mistakes_menu = mistakes_menues[language]
	mistakes_menu.clear_buttons()
	var mistakes = SaveServer.load_mistakes(language)
	mistakes_menu.visible = mistakes.size() > 0
	for mistake_res in mistakes:
		var mistake = mistake_res.mistake
		var button = mistakes_menu.add_option_scene_button(MISTAKE_BUTTON)
		button.text = mistake





# -------------------------------



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







