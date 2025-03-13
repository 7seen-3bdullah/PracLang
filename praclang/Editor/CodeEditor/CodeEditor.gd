extends FlexibleControl

@export var source_language: String

@onready var code_edit: CodeEdit = %CodeEdit
@onready var shortcut_node: ShortcutNode = %ShortcutNode

@onready var gen_code_button: Button = %GenCodeButton
@onready var edit_code_button: Button = %EditCodeButton
@onready var gen_comment_button: Button = %GenCommentButton
@onready var trans_language_button: Button = %TransLanguageButton

@onready var gen_code_interface: AIInterface = %GenCodeInterface
@onready var edit_code_interface: AIInterface = %EditCodeInterface
@onready var gen_command_interface: AIInterface = %GenCommandInterface
@onready var trans_language_interface: AIInterface = %TransLanguageInterface
@onready var prediction_interface: AIInterface = %PredictionInterface


var ai_processing_rect: ColorRect


# --------------------------------------------------------------


func _ready() -> void:
	super()
	focus_changed.connect(on_focus_changed)
	
	gen_code_button.pressed.connect(on_generate_code_button_pressed)
	edit_code_button.pressed.connect(on_edit_code_button_pressed)
	gen_comment_button.pressed.connect(on_generate_command_button_pressed)
	trans_language_button.pressed.connect(on_trans_language_button_pressed)
	
	gen_code_interface.result_pushed.connect(on_gen_code_order_pushed)
	edit_code_interface.result_pushed.connect(on_edit_code_order_pushed)
	gen_command_interface.result_pushed.connect(on_gen_command_order_pushed)
	trans_language_interface.result_pushed.connect(on_trans_language_order_pushed)
	prediction_interface.result_pushed.connect(on_prediction_order_pushed)

# --------------------------------------------------------------


func on_focus_changed(is_focus: bool) -> void:
	if is_focus:
		await get_tree().process_frame
		GuideServer.push_guides([
			{"Gen Code": "Control+G"},
			{"Edit Code": "Control+E"},
			{"Gen Command": "Control+O"},
			{"Trans Language": "Control+T"},
			{"Predicte Code": "Control+Q"},
			{"Zoom In Out": "'Scroll Mouse Wheel'"}
		])
	else:
		GuideServer.push_guides()

func on_generate_code_button_pressed() -> void:
	generate_code()

func on_edit_code_button_pressed() -> void:
	edit_code()

func on_generate_command_button_pressed() -> void:
	generate_command()

func on_trans_language_button_pressed() -> void:
	translate_language()


# --------------------------------------------------------------


func generate_code() -> void:
	shortcut_node.set_enabled(false)
	var window = WindowManager.popup_window(get_owner(), Vector2(500, 200), "Generate New Code")
	var description_edit = window.expand_control(window.add_text("What code do you want to generate?", ""))
	var accept_button = window.add_button("Accept",
		func():
			var text = description_edit.get_text()
			if text:
				gen_code_interface.send_message(
					str(
						"سيتم إرسال إليك رسالة بكتابة كود باستخدام لغة " + source_language, "\n",
						"نفذ الطلب, ولكن إذا كانت الرسالة لا تتعلق بكتابة كود برمجي بأي حال من الأحوال, أرسل رسالة تحتوي على '-' فقط", "\n",
						"إذا تم الطلب بلغة مختلفة اصنعه لا مشكلة, ولكن إذا لم يتم التحديد اصنعه باللغة المذكورة أعلاه", "\n",
						"الرسالة:", "\n", text,
						"لا تضف أي مقدمة أو شرح، فقط أرسل المطلوب", "\n",
					)
				)
				add_ai_processing_rect()
			else:
				GuideServer.push_message("You need to enter your request for the AI assistant to process it.", 1)
			window.close_requested.emit()
	)
	window.close_requested.connect(shortcut_node.set_enabled.bind(true))

func edit_code() -> void:
	var selected_text = code_edit.get_selected_text()
	if not selected_text:
		GuideServer.push_message("You must select the code or a part of it to modify.", 1)
		return
	
	shortcut_node.set_enabled(false)
	var window = WindowManager.popup_window(get_owner(), Vector2i(400, 400), "Edit Code")
	var display_text: TextEdit = window.expand_control(window.add_text("", selected_text))
	var description_edit = window.add_line("What do you want to Edit ?", "")
	var accept_button = window.add_button("Accept",
		func():
			var text = description_edit.get_text()
			if text:
				edit_code_interface.send_message(
					str(
						"هذا هو الكود بلغة ", source_language, ":", "\n", selected_text,
						"سوف يتم إرسال إليك رسالة أدناه, إذا كانت الرسالة عبارة عن أمر بالتعديل على الكود أعلاه أرسل التعديل, وإذا كانت أي شيء آخر أرسل رسالة تحتوي على '-' فقط",
						"لا تضف أي مقدمة أو شرح، فقط أرسل المطلوب", "\n",
						"الرسالة:", "\n", text, "\n",
					)
				)
				add_ai_processing_rect()
			else:
				GuideServer.push_message("You need to enter a command for the AI assistant to process your request.", 1)
			window.close_requested.emit()
	)
	display_text.set_editable(false)
	display_text.add_theme_font_size_override("font_size", 14)
	display_text.add_theme_font_override("font", code_edit.get_theme_font("font"))
	display_text.set_syntax_highlighter(code_edit.syntax_highlighter.duplicate(true))
	window.close_requested.connect(shortcut_node.set_enabled.bind(true))
	window.unresizable = true

func generate_command() -> void:
	shortcut_node.set_enabled(false)
	gen_command_interface.send_message(
		str("قم بإضافة التعليقات المختصرة والمفيدة لهذا الكود البرمجي", "\n",
		code_edit.get_text(), "\n",
		"لا تضف أي مقدمة أو شرح، فقط أضف التعليقات في الكود.", "\n",
		)
	)
	add_ai_processing_rect()

func translate_language() -> void:
	shortcut_node.set_enabled(false)
	var window = WindowManager.popup_window(get_owner(), Vector2i(300, 110), "Translate Language")
	var source_lang_edit = window.add_line("Source Language ...", source_language)
	var target_lang_edit = window.add_line("Target Language ...", "")
	var accept_button = window.add_button("Accept",
		func():
			var source_lang = source_lang_edit.get_text()
			var target_lang = target_lang_edit.get_text()
			if source_lang and target_lang:
				trans_language_interface.send_message(
					str(
						"سوف يتم إرسال رسالة إليك تحتوي على كود ولغة البرمجة المصدر واللغة الهدف, وظيفتك التحويل من المصدر إلى الهدف", "\n",
						"إذا كانت اللغات المدخلة هي لغات برمجة تعرفها أرسل التحويل إلى الهدف, وإذا لم تكن تعرف واحدة منهما أرسل '-'", "\n",
						"لا تضف أي مقدمة أو شرح، فقط أرسل المطلوب", "\n",
						"الرسالة:", "\n",
						"الكود:", code_edit.get_text(), "\n", "اللغة المصدر: ", source_lang, "\n", "اللغة الهدف: ", target_lang
					)
				)
				add_ai_processing_rect()
			else:
				GuideServer.push_message("You need to write the source language and the target language.", 1)
			window.close_requested.emit()
	)
	window.close_requested.connect(shortcut_node.set_enabled.bind(true))
	window.unresizable = true


const MENU_BOX = preload("res://UI&UX/MenuBox/MenuBox.tscn")
const CODE_BUTTON = preload("res://UI&UX/MenuBox/CodeButton.tscn")
var prediction_code_buttons: Array[Control]
var imagine_window: Window
var imagine_process_rect: ColorRect

func imagine_code() -> void:
	var selected_text = code_edit.get_selected_text()
	if not selected_text:
		GuideServer.push_message("You must select a text to Imagine.", 1)
		return
	
	shortcut_node.set_enabled(false)
	var prediction_times:= 5
	var window_pos = get_window().position + Vector2i(get_global_mouse_position())
	var window_size = Vector2i(300, 80)
	var window = WindowManager.popup_window(get_owner(), window_size, "Predictive code")
	var predict_button = window.add_button("Predict")
	var close_button = window.add_button("Close")
	var menu_box = window.add_scene(MENU_BOX)
	
	prediction_code_buttons.clear()
	predict_button.pressed.connect(
		func():
			prediction_interface.send_message(
			str(
				"أرسل التكملات الممكنة في هذا الكود:", "\n", selected_text, "\n",
				"يجب إرسال التكملات المتوقعة كملف json على النحو التالي:", "\n",
				"{
					\"predictions\": [
						\"complete 1 code\",
						\"complete 2 code\",
						\"complete 3 code\",
						...
					]
				}", "\n",
				"مع العلم أن الكود الكامل هو:", "\n", code_edit.get_text(),
				"عدد التكملات المطلوب هو:", prediction_times, "\n",
				"انتبه, في كل تكملة حاول أن تكمل جزئية الكود, ولكن لا تعد كتابة كل شيء", "\n",
				"لا تضف أي مقدمة أو شرح أو تعليق، فقط أرسل المطلوب", "\n"
				)
			)
			imagine_process_rect = WindowManager.create_processing_rect()
			window.add_child(imagine_process_rect)
	)
	close_button.pressed.connect(func(): window.close_requested.emit())
	menu_box.button_pressed.connect(
		func(button: Control) -> void:
			code_edit.insert_text_at_caret(str(selected_text, "\n", button.code))
			window.close_requested.emit()
	)
	for i in prediction_times:
		var code_button = menu_box.add_option_scene_button(CODE_BUTTON)
		prediction_code_buttons.append(code_button)
		code_button.hide()
	
	window.close_requested.connect(shortcut_node.set_enabled.bind(true))
	window.unresizable = true
	window.popup(Rect2(window_pos, window_size))
	imagine_window = window



# --------------------------------------------------------------


const ERROR_KEY:= "-"

func on_gen_code_order_pushed(error: int, response: Dictionary) -> void:
	var message = extract_message(response)
	if message == ERROR_KEY:
		push_process_problem()
	else:
		await set_extracted_code(message)
	remove_ai_processing_rect()

func on_edit_code_order_pushed(error: int, response: Dictionary) -> void:
	var message = extract_message(response)
	if message == ERROR_KEY:
		push_process_problem()
	else:
		var new_part = extract_code(message)
		code_edit.insert_text_at_caret(new_part)
	remove_ai_processing_rect()

func on_gen_command_order_pushed(error: int, response: Dictionary) -> void:
	set_extracted_code(extract_message(response))
	remove_ai_processing_rect()

func on_trans_language_order_pushed(error: int, response: Dictionary) -> void:
	var message = extract_message(response)
	if message == ERROR_KEY:
		push_process_problem()
	else:
		await set_extracted_code(message)
	remove_ai_processing_rect()

func on_prediction_order_pushed(error: int, response: Dictionary) -> void:
	var message = extract_message(response)
	if message == ERROR_KEY:
		push_process_problem()
	else:
		var json_string = extract_code(message)
		var json = JSON.new()
		var result = json.parse_string(json_string)
		if not result:
			push_process_problem()
			return
		var predictions = result.predictions
		for index in predictions.size():
			if index >= prediction_code_buttons.size():
				return
			var button = prediction_code_buttons[index]
			var code = predictions[index]
			button.show()
			button.code = code
			button.highlight = code_edit.syntax_highlighter.duplicate(true)
	imagine_process_rect.hide()
	for i in 2:
		imagine_window.remove_control(i)
	imagine_window.set_size(Vector2i(600, 400))


# --------------------------------------------------------------


func set_extracted_code(message: String) -> void:
	var new_code = extract_code(message)
	await set_code_edit_text(new_code)


func set_code_edit_text(new_text: String) -> void:
	var lines = new_text.split("\n")
	code_edit.set_text("")
	for index in lines.size():
		var line = lines[index]
		code_edit.text += line + "\n"
		await get_tree().process_frame

func extract_message(response: Dictionary) -> String:
	if not response.has("choices"):
		return ERROR_KEY
	return response["choices"][0]["message"]["content"].strip_edges()

func extract_code(message: String) -> String:
	var code: String
	var splited_message = message.split("\n")
	splited_message.remove_at(0)
	for i in splited_message:
		if i in ["```", "```gdscript", "```json"]:
			continue
		code += i + "\n"
	return code

func push_process_problem() -> void:
	GuideServer.push_message("We were unable to process your request.", 2)

func add_ai_processing_rect() -> void:
	var processing_rect = WindowManager.create_processing_rect()
	ai_processing_rect = processing_rect
	get_owner().add_child(processing_rect)

func remove_ai_processing_rect() -> void:
	if is_instance_valid(ai_processing_rect):
		ai_processing_rect.queue_free()
	shortcut_node.set_enabled(true)


