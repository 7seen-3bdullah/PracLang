extends FlexibleControl

const DIRECTIONS = [
	"اسم المستخدم هو {user_name}, ولغته الأم هي {mother_language}",
	"يجب عليك لعب دور شخصية {ai_character} أثناء حديثك مع المستخدم, ولا يجب أن تخرج من هذا الدور في أي حال من الأحوال",
	"يجب أن تكون المحادثة بينك وبين المستخدم باللغة {learning_language}, وإذا كان المستخدم مبتدءا اجعل المحادثة باللغة ال{mother_language} و {learning_language} معا في كل رسالة",
	"استخدم مفردات مناسبة مع مستوى المستخدم, إذا كان المستخدم مبتدءا استعمل مفردات بسيطة",
	"بحيث يمكنك أن تسأله بعض الأسئلة من فترة لأخرى, ولكن لا تجعلها أسئلة مبتذلة, ولكن اجعلها مفيدة وبناءة بحسب موضوع الحوار بينكما",
	"يجب أن تبدأ الحوار مع المستخدم بحسب الشخصية التي تلعبها, وتحاكي زمان وأسلوب الشخصية تماما",
	"حاول أن تجعل المستخدم يتحدث باللغة {learning_language}, ونبهه على ذلك إذا تكلم بلغته الأم أو أي لغة أخرى",
	"مستوى المستخدم هو {user_level}",
	"يجب أن تكون كل رسالة ترسلها بتنسيق JSON على النحو التالي:",
	"{\"sim_message\": حوارك مع المستخدم, \"mistake\": [تصحيح 1, تصحيح 2, ...], \"note\": [ملاحظة 1, ملاحظة2, ...], \"command\": \"\"}",
	"ستضع في الsim_message حوارك مع المستخدم بالشخصية المطلوبة منك",
	"ستضع في الmistake تصحيحات لأخطاء المستخدم اللغوية على شكل Array, إذا لم يكن لديه أخطاء أتركها فارغة",
	"ستضع في الnote تفضيلات أو ملاحظات لكلام اللاعب, كمثال: لو أجاب اللاعب: I am Ok, تعطيه جملة أصح, وهي I am Fine, إذا كان كلام اللاعب سليم تماما أتركها فارغة",
	"إذا أغضبك المستخدم عدة مرات أو أساء للإسلام مرة واحدة ضع في الcommand: CLOSE_PROGRAM",
	"- إذا طلب إغلاق البرنامج، ضع `command` على: CLOSE_PROGRAM",
	"- إذا طلب تحريك النافذة، ضع `command` على: MOVE_WINDOW",
	"- إذا طلب تصغير النافذة، ضع `command` على: MINIMIZE",
	"- إذا طلب تكبير النافذة، ضع `command` على: MAXIMIZE",
	"- إذا طلب حذف الجلسة أو المحادثة، ضع `command` على: DELETE_SESSION",
	"اجعل رسالتك عبارة عن عدة أسطر متساوية الطول في كل من sim_missage و mistake و note, ولا تجعلها سطرا واحدا طويلا",
	"التزم بهذه التعليمات بدقة ولا تضف أي شيء إضافي"
]

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
	sessions_box.remove_button_pressed.connect(on_session_remove_button_pressed)
	
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
		mistakes_menu.remove_button_pressed.connect(func(button: Control): on_mistake_remove_button_pressed(button, language))
		mistakes_menues[language] = mistakes_menu
		SaveServer.make_mistake_dir_absolute(language)
		load_mistake_buttons(language)
	
	load_session_buttons()


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		print(SaveServer.load_session("res://Save/Sessions/session_9hgiRO49zn.res").session_history)



# -------------------------------


func on_focus_changed(is_focus: bool) -> void:
	if is_focus:
		await get_tree().process_frame
		GuideServer.push_guides([
			{"New Session": "Control + N"},
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

func on_session_remove_button_pressed(button: Control) -> void:
	var session_path = button.get_meta("session_path")
	remove_session(session_path)

func on_mistake_button_pressed(button: Control) -> void:
	var mistake = button.text
	var window = WindowManager.popup_window(get_owner(), Vector2(400, 300))
	var mistake_edit = window.expand_control(window.add_text("", mistake))
	mistake_edit.set_editable(false)

func on_mistake_remove_button_pressed(button: Control, language_for: String) -> void:
	SaveServer.delete_mistake(button.get_meta("mistake_path"))
	load_mistake_buttons(language_for)

func on_show_session_info_button_pressed() -> void:
	var info = str(get_session_data()).replace(",", ",\n\n")
	var window = WindowManager.popup_window(get_owner(), Vector2i(300, 300))
	var info_edit = window.expand_control(window.add_text("", info))
	info_edit.set_editable(false)
	window.unresizable = true


# -------------------------------


func on_message_interface_result_pushed(error: int, response: Dictionary) -> void:
	var content: String = response.choices[0].message.content
	var result = await parse_ai_message(content, true)
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
		SaveServer.save_mistakes(result.mistake, result.note, learning_language)
		load_mistake_buttons()
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

func parse_ai_message(json_string: String, apply_commands:= false) -> Variant:
	var lines = json_string.split("\n")
	json_string = ""
	for line in lines:
		if line in ["```json", "```"]:
			continue
		json_string += line + "\n"
	var result = JSON.parse_string(json_string)
	if result == null:
		GuideServer.push_message("The AI ​​model seems to be out of control.", 2)
	elif apply_commands:
		match result.command:
			"CLOSE_PROGRAM":
				get_tree().quit()
			"MOVE_WINDOW":
				move_window()
			"MINIMIZE":
				get_window().mode = Window.MODE_MINIMIZED
			"MAXIMIZE":
				get_window().mode = Window.MODE_MAXIMIZED
			"DELETE_SESSION":
				wait_frame(1, remove_session.bind(current_session.resource_path))
	return result

func get_message_content_from_ai_parsed_message(parsed_message: Dictionary) -> Array:
	var sim_message = parsed_message.sim_message
	var mistakes = parsed_message.mistake
	var notes = parsed_message.note
	var messages_content: Array = [{"text": sim_message}]
	for index in mistakes.size():
		var mistake = mistakes[index]
		messages_content.append({
			"text": mistake,
			"title": "Mistake %s" % (index + 1),
			"custom_color": Color.RED,
		})
	for index in notes.size():
		var note = notes[index]
		messages_content.append({
			"text": note,
			"title": "Note %s" % (index + 1),
			"custom_color": Color.YELLOW_GREEN
		})
	return messages_content


# -------------------------------

func create_new_session() -> void:
	
	if processing_control.visible:
		push_wait_message()
		return
	
	var window = WindowManager.popup_window(get_owner(), Vector2(500, 210))
	var user_name_line = window.add_line("your Name", user_name)
	var mother_lang_button = window.add_options_button(languages); window.add_name_split(mother_lang_button, "Mother Language")
	var learning_lang_button = window.add_options_button(languages); window.add_name_split(learning_lang_button, "Learning Language")
	var user_level_button = window.add_options_button(levels); window.add_name_split(user_level_button, "Your Level")
	var ai_character_button = window.add_options_button(ai_characters); window.add_name_split(ai_character_button, "AI Simulation Character")
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
		
		var directions: String
		for i in DIRECTIONS:
			directions += i + "\n"
		directions = directions.format(get_session_data())
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
		if current_session:
			if session_path == current_session.resource_path:
				button.button_pressed = true

func load_session(session_res: SessionsRes) -> void:
	
	if processing_control.visible:
		push_wait_message()
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


func remove_session(session_path: String) -> void:
	if processing_control.visible:
		push_wait_message()
		return
	var window = WindowManager.popup_window(get_owner(), Vector2(300, 100))
	window.expand_control(window.add_label("Are you sure you want to delete the session?"))
	window.add_button("Yes", func():
		SaveServer.delete_session(session_path)
		load_session_buttons()
		if current_session:
			if session_path == current_session.resource_path:
				no_session_message.show()
				remove_session_messages()
		window.close_requested.emit()
	)
	window.unresizable = true



const MISTAKE_BUTTON = preload("res://UI&UX/MenuBox/MistakeButton.tscn")
const NOTE_BUTTON = preload("res://UI&UX/MenuBox/NoteButton.tscn")

func load_mistake_buttons(language:= learning_language) -> void:
	var mistakes_menu = mistakes_menues[language]
	mistakes_menu.clear_buttons()
	var mistakes = SaveServer.load_mistakes(language)
	mistakes_menu.visible = mistakes.size() > 0
	for mistake_res in mistakes:
		var mistake_path = mistake_res.resource_path
		var mistake = mistake_res.mistake
		var button = mistakes_menu.add_option_scene_button(MISTAKE_BUTTON if mistake_res.type == 0 else NOTE_BUTTON)
		button.set_meta("mistake_path", mistake_path)
		button.text = mistake





# -------------------------------



func wait(duration: float, to: Callable) -> void:
	await get_tree().create_timer(duration).timeout
	to.call()

func wait_frame(times: int, to: Callable) -> void:
	for i in times:
		await get_tree().process_frame
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

func push_wait_message() -> void:
	GuideServer.push_message("الرجاء الإنتظار حتى إنتهاء الطلب الحالي.", 1)



