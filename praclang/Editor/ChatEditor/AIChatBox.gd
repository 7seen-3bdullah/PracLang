extends FlexibleControl

const DIRECTIONS = [
	"اسم المستخدم هو {user_name}, ولغته الأم هي {mother_language}",
	"يجب عليك لعب دور شخصية {ai_character} أثناء حديثك مع المستخدم, ولا يجب أن تخرج من هذا الدور في أي حال من الأحوال",
	"يجب أن تكون المحادثة بينك وبين المستخدم باللغة {learning_language}",
	"إذا كان المستخدم مبتدأ A1 أو A2 ترجم كل جملة تقولها",
	"استخدم مفردات مناسبة مع مستوى المستخدم, إذا كان المستخدم A1 استعمل مفردات بسيطة",
	"بحيث يمكنك أن تسأله بعض الأسئلة من فترة لأخرى, ولكن لا تجعلها أسئلة مبتذلة, ولكن اجعلها مفيدة وبناءة بحسب موضوع الحوار بينكما",
	"يجب أن تبدأ الحوار مع المستخدم بحسب الشخصية التي تلعبها, وتحاكي زمان وأسلوب الشخصية تماما",
	"حاول أن تجعل المستخدم يتحدث باللغة {learning_language}, ونبهه على ذلك إذا تكلم بلغته الأم أو أي لغة أخرى",
	"بإمكانك استخدام الEmojies من الحين والآخر",
	"مستوى المستخدم هو {user_level}",
	"يجب أن تكون كل رسالة ترسلها بتنسيق JSON على النحو التالي:",
	"{\"sim_message\": حوارك مع المستخدم, \"mistake\": [تصحيح 1, تصحيح 2, ...], \"note\": [ملاحظة 1, ملاحظة2, ...], \"command\": \"\"}",
	"ستضع في الsim_message حوارك مع المستخدم بالشخصية المطلوبة منك",
	"ستضع في الmistake أخطاء المستخدم مع تصحيحات لها, لا تضع سوى الأخطاء المهمة, أما إن كان خطأ كتابي أو أيا كان لا تضعه, لا تركز كثيرا على جزئية الmistake إلا إذا كان خطأ كبيرا",
	"ستضع في الnote تفضيلات أو ملاحظات لكلام المستخدم, كمثال: لو أجاب المستخدم: I am Ok, تعطيه جملة أصح, وهي I am Fine, إذا كان كلام المستخدم سليم تماما أتركها فارغة",
	"اجعل جميع التصحيحات باللغة الأم {mother_language}",
	"إذا أغضبك المستخدم عدة مرات أو أساء للإسلام مرة واحدة ضع في الcommand: CLOSE_PROGRAM",
	"- إذا طلب إغلاق البرنامج، ضع `command` على: CLOSE_PROGRAM",
	"- إذا طلب تحريك النافذة، ضع `command` على: MOVE_WINDOW",
	"- إذا طلب تصغير النافذة، ضع `command` على: MINIMIZE",
	"- إذا طلب تكبير النافذة، ضع `command` على: MAXIMIZE",
	"- إذا طلب حذف الجلسة أو المحادثة، ضع `command` على: DELETE_SESSION",
	"اجعل رسالتك عبارة عن عدة أسطر متساوية الطول في كل من sim_missage و mistake و note, ولا تجعلها سطرا واحدا طويلا, يجب أن يتألف السطر الواحد على 8 كلمات أو أقل, لا تزد عن 8",
	"التزم بهذه التعليمات بدقة ولا تضف أي شيء إضافي"
]

@export var languages: Array[String]
@export var levels: Array[String]
@export var ai_characters: Array[String]
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

@onready var about_button: Button = %AboutButton
@onready var show_session_info_button: Button = %ShowSessionInfoButton
@onready var code_editor_button: Button = %CodeEditorButton

@onready var completions_box: VBoxContainer = %CompletionsBox
@onready var session_info_side: ColorRect = %SessionInfoSide
@onready var session_preview: CopiedCodeEdit = %SessionPreview
@onready var certificate_panel: PanelContainer = %CertificatePanel
@onready var certificate_label: Label = %CertificateLabel



var mistakes_menues: Dictionary[String, Control]
var user_current_message: Control

var completion_index: int
var can_change_session:= true
var previous_text: String = ""

const MENU_BOX = preload("res://UI&UX/MenuBox/MenuBox.tscn")
const COMPLETION_BOX = preload("res://UI&UX/CompletionBox.tscn")










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
	
	about_button.pressed.connect(on_about_button_pressed)
	show_session_info_button.pressed.connect(on_show_session_info_button_pressed)
	code_editor_button.pressed.connect(on_code_editor_button_pressed)
	
	message_line.set_editable(false)
	
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




# -------------------------------

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ENTER:
			return
		await get_tree().process_frame
		var current_text = message_line.get_text()
		if current_text != previous_text:
			previous_text = current_text
			Sounds.Typing_Sound()

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
		GlobalTween.shake(message_line, 50, 0.05)
		return
	message_line.set_editable(false)
	await get_tree().process_frame
	message_interface.send_message(message)
	message_line.clear()
	add_message_box(user_name, [{"text": message}])
	processing_control.show()
	
	Sounds.Send_Message_Sound(0.7, -15.0)

func on_session_button_pressed(button: Control) -> void:
	var session_path = button.get_meta("session_path")
	var session_res = SaveServer.load_session(session_path)
	preview_session(session_res)

func on_session_remove_button_pressed(button: Control) -> void:
	var session_path = button.get_meta("session_path")
	remove_session(session_path)
	
	Sounds.Click_Sound(1,-10)

func on_mistake_button_pressed(button: Control) -> void:
	var mistake = button.text
	var window = WindowManager.popup_window(get_owner(), Vector2(400, 300))
	var mistake_edit = window.expand_control(window.add_text("", mistake))
	mistake_edit.set_editable(false)
	
	Sounds.Click_Sound(1,-10)

func on_mistake_remove_button_pressed(button: Control, language_for: String) -> void:
	SaveServer.delete_mistake(button.get_meta("mistake_path"))
	load_mistake_buttons(language_for)
	
	Sounds.Click_Sound(1,-10)


func on_about_button_pressed() -> void:
	var window = WindowManager.popup_window(get_owner(), Vector2(900, 150))
	var label: Label = window.expand_control(window.add_label("PracLang is a program for learning natural languages through an engaging conversation with artificial intelligence.
	This program offers a free solution for learning languages practically and interactively by conversing with the character of your choice.
	-----------------------------------------------------------------
	In this program, we used the Gemini 2.0 Experimental Pro model."))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	window.unresizable = true
	Sounds.Click_Sound(1,-10)


func on_show_session_info_button_pressed() -> void:
	var info = str(get_session_data()).replace(",", ",\n\n")
	var window = WindowManager.popup_window(get_owner(), Vector2i(300, 300))
	var info_edit = window.expand_control(window.add_text("", info))
	info_edit.set_editable(false)
	window.unresizable = true
	Sounds.Click_Sound(1,-10)

const CODE_EDITOR = preload("res://Editor/CodeEditor/CodeEditor.tscn")
func on_code_editor_button_pressed() -> void:
	var window_size = Vector2i(800, 500)
	var window = WindowManager.popup_window(get_owner(), window_size)
	window.add_label("The AI-powered text editor was the initial goal of this project\nbut when the idea changed, we kept it here for display purposes only.")
	window.expand_control(window.add_scene(CODE_EDITOR))
	window.min_size = window_size
	Sounds.Click_Sound(1,-10)











# -------------------------------













func on_message_interface_result_pushed(error: int, response: Dictionary) -> void:
	var content: String = response.choices[0].message.content
	var result = await parse_ai_message(content, true)
	if result != null:
		var messages_content = get_message_content_from_ai_parsed_message(result)
		add_message_box("AI", messages_content)
		processing_control.hide()
		await get_tree().process_frame
		if result.mistake:
			level_append(-4.0)
			Sounds.Error_sound("mistake",1)
		else:
			level_append(current_session.level_up_speed)
			current_session.level_up_speed -= 5
			current_session.level_up_speed = max(current_session.level_up_speed, 20)
			Sounds.Send_Message_Sound(1.9, -10.0)
		current_session = SaveServer.save_session(
			message_interface.chat_history,
			get_session_data(),
			current_session.completions,
			current_session.level_up_speed,
			current_session.resource_path
		)
		SaveServer.save_mistakes(result.mistake, result.note, learning_language)
		load_mistake_buttons()
	else:
		GuideServer.push_message("problem with AI", 2)
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
	
	GlobalTween.squish(message_box, Vector2(1.2,0.8), 0.1)
	
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
	if not can_change_session:
		return
	
	var window = WindowManager.popup_window(get_owner(), Vector2(500, 230))
	var session_name_line = window.add_line("Session Name", "")
	var user_name_line = window.add_line("Your Name", user_name)
	var mother_lang_button = window.add_options_button(languages); window.add_name_split(mother_lang_button, "Mother Language")
	var learning_lang_button = window.add_options_button(languages); window.add_name_split(learning_lang_button, "Learning Language")
	var user_level_button = window.add_options_button(levels); window.add_name_split(user_level_button, "Your Level")
	var ai_character_button = window.add_options_button(ai_characters); window.add_name_split(ai_character_button, "AI Simulation Character")
	window.add_button("Accept", func():
		
		var session_filenames = SaveServer.get_sessions_filenames()
		if session_filenames.has(session_name_line.text + ".res"):
			GuideServer.push_message("This session name has been used", 1)
			return
		if not session_name_line.text or not user_name_line.text:
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
		current_session = SaveServer.save_session(message_interface.chat_history, get_session_data(), null, 50, "", session_name_line.text)
		preview_session_info(current_session)
		load_session_buttons()
		window.close_requested.emit()
	)
	var valid_line_text = func(line: LineEdit, new_text: String):
		var regex = RegEx.new()
		regex.compile("^[\\p{L}\\d\\s]+$")  # أضفنا \d لتشمل الأرقام
		if not regex.search(new_text):
			line.text = ""
	
	session_name_line.text_changed.connect(func(new_text: String): valid_line_text.call(session_name_line, new_text))
	user_name_line.text_changed.connect(func(new_text: String): valid_line_text.call(user_name_line, new_text))
	
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

func preview_session(session_res: SessionsRes) -> void:
	
	if current_session:
		if session_res.resource_path == current_session.resource_path:
			return
	if processing_control.visible:
		push_wait_message()
		return
	if not can_change_session:
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
				if message_result == null:
					continue
				var messages_content = get_message_content_from_ai_parsed_message(message_result)
				add_message_box("AI", messages_content)
			_:
				add_message_box(user_name, [{"text": content[0].text}])
	
	preview_session_info(session_res)



func preview_session_info(session_res: SessionsRes) -> void:
	session_info_side.show()
	certificate_panel.hide()
	session_preview.text = str(get_session_data()).replace(",", ",\n")
	var completions = session_res.completions
	for i in completions_box.get_children(): i.queue_free()
	can_change_session = false
	completion_index = -1
	for index: int in completions:
		var completion = completions[index]
		var completed = completion.completed
		var color = completion.color
		var completion_box = COMPLETION_BOX.instantiate()
		var current = completion_index < 0 and completed < 100.0
		completions_box.add_child(completion_box)
		completion_box.setup(index + 1, completed, color, current)
		if current:
			completion_index = index
		if index % 2:
			await get_tree().create_timer(.1).timeout
	if completion_index == -1:
		show_certificate()
	can_change_session = true


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
				session_info_side.hide()
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
	GuideServer.push_message("Please wait until the current request is completed.", 1)


func level_append(append: float) -> void:
	if certificate_panel.visible:
		return
	var res_completions = current_session.completions
	res_completions[completion_index].completed += append
	var curr_completion_box = completions_box.get_children()[completion_index]
	curr_completion_box.append_completion(append)
	curr_completion_box.notificate(Color.GREEN_YELLOW if append > 0 else Color.ORANGE)
	if res_completions[completion_index].completed >= 100.0:
		if completion_index < res_completions.size() - 1:
			completion_index += 1
			completions_box.get_children()[completion_index].current = true
			Sounds.Error_sound("finsh", 1)
		else:
			var window = WindowManager.popup_window(get_owner(), Vector2i(200, 100))
			window.add_label("Congratulations! You have completed the session")
			window.unresizable = true
			show_certificate()


func show_certificate() -> void:
	certificate_panel.show()
	certificate_label.set_text(
		"بسم الله الرحمن الرحيم\nAll praise is due to Allah, by whose grace good deeds are completed\nA session has been completed at level {user_level} in the language: {learning_language}"
		.format(get_session_data())
	)
