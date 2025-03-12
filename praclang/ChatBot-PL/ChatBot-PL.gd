extends Node

@onready var line_edit: LineEdit = $PanelContainer/VBoxContainer/LineEdit
@onready var rich_text_label: RichTextLabel = $PanelContainer/VBoxContainer/ScrollContainer/RichTextLabel

const OPENROUTER_API_KEY = "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"

# User preferences (can be set via UI or other logic)
var user_name = "Anas"
var help_language = "Arabic"
var user_language = "English"  # Language the user wants to learn
var user_level = "normal"   # User's proficiency level (e.g., Beginner, Intermediate, Advanced)
var ai_character = "strict Teacher"  # AI's character (e.g., Friendly Tutor, Strict Teacher, Funny Companion)

# Conversation history
var conversation_history = []

func _ready():
	# Start the conversation
	start_conversation()

func start_conversation():
	# Create a system message to define the AI's behavior
	var system_message = (
		"You are a {character} helping the user practice {language}. " +
		"The user's level in the language is {level}. " +
		"Start a conversation in {language} that is appropriate for their level. " +
		"Keep the conversation engaging and educational. " +
		"The user's name is {name}"+
		"If the user makes mistakes, gently correct them and explain the correct usage,
		and before correcting any mistake print [Mistake], and use the {mother_language} while correcting."+
		"use short sentences [10 words maximum], and don't ask more than one question in the message"+
		"never stop the simulation until the user sends [stpsim] and never tell him how to stop the simulation"
	).format({
		"character": ai_character,
		"language": user_language,
		"level": user_level,
		"name":user_name,
		"mother_language":help_language
	})
	
	# Initialize the conversation history with the system message and AI's greeting
	conversation_history = [
		{
			"role": "system",
			"content": system_message
		},
		{
			"role": "assistant",
			"content": "Hello! Let's practice " + user_language + ". How can I help you today?"
		}
	]
	
	# Send the initial conversation to the AI
	send_openrouter_request(conversation_history)

func send_user_message(user_message: String):
	# Add the user's message to the conversation history
	conversation_history.append({
		"role": "user",
		"content": user_message
	})
	
	# Send the updated conversation to the AI
	send_openrouter_request(conversation_history)

func send_openrouter_request(messages: Array):
	var url = "https://openrouter.ai/api/v1/chat/completions"
	var headers = [
		"Authorization: Bearer " + OPENROUTER_API_KEY,
		"Content-Type: application/json"
	]
	
	var body = {
		"model": "google/gemini-2.0-pro-exp-02-05:free",
		"messages": messages
	}
	
	var json_body = JSON.stringify(body)
	
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", Callable(self, "_on_request_completed"))
	http_request.request(url, headers, HTTPClient.METHOD_POST, json_body)

func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	if response_code == 200:
		var json = JSON.new()
		var parse_result = json.parse(body.get_string_from_utf8())
		if parse_result == OK:
			var response = json.get_data()
			if response.has("choices") and response["choices"].size() > 0:
				var ai_message = response["choices"][0]["message"]["content"]
				# Display the AI's response in the RichTextLabel
				rich_text_label.text += "AI: " + ai_message + "\n"
				
				# Add the AI's response to the conversation history
				conversation_history.append({
					"role": "assistant",
					"content": ai_message
				})
			else:
				print("No message found in response.")
		else:
			print("Failed to parse JSON response.")
	else:
		print("Request failed with response code: ", response_code)

func _input(event: InputEvent):
	if event.is_action_pressed("send"):
		var user_message = line_edit.text.strip_edges()
		if user_message != "":
			# Display the user's message in the RichTextLabel
			rich_text_label.text += "You: " + user_message + "\n"
			line_edit.text = ""  # Clear the input field
			
			# Send the user's message to the AI
			send_user_message(user_message)
