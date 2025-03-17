class_name AIInterface extends Node

signal result_pushed(error: int, response: Dictionary)
signal error_result_pushed(error: int, response: Dictionary)
signal error_pushed()

@export var api_key: String
@export_multiline var directions: String
@export var use_history:= true
@export var try_again_on_failed: bool
var chat_history: Array = []

@onready var http_request = HTTPRequest.new()

const API_URL = "https://openrouter.ai/api/v1/chat/completions"
const API_KEY = "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" # from Omar TOP account
const API_KEY2 = "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" # from Omar TOP account 2
const API_KEY3 = "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" # from DMG4 account
const API_KEY4 = "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" # from Hussain Abdullah

func _ready() -> void:
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)
	add_to_group("ai_interface")
	if directions:
		setup_directions(directions)

func setup_directions(directions: String) -> void:
	chat_history.append({
		"role": "system",
		"content": directions
	})
	request_ai()

func send_message(message: String) -> void:
	chat_history.append({"role": "user", "content": [{"type": "text", "text": message}]})
	request_ai()
	if not use_history:
		chat_history.clear()

func request_ai() -> void:
	var headers = [
		"Authorization: Bearer " + API_KEY3,
		"Content-Type: application/json"
	]
	var body = {
		"model": "google/gemini-2.0-pro-exp-02-05:free",
		"messages": chat_history
	}
	var json_body = JSON.stringify(body)
	var error = http_request.request(API_URL, headers, HTTPClient.METHOD_POST, json_body)
	if error != OK:
		push_connection_error()

func _on_request_completed(result, response_code, headers, body) -> void:
	var remove_last_chat:= true
	if response_code == 200:
		var response = JSON.parse_string(body.get_string_from_utf8())
		if response.size():
			if response.has("choices"):
				result_pushed.emit(response_code, response)
				if use_history:
					chat_history.append(response["choices"][0]["message"])
					remove_last_chat = false
			else:
				error_result_pushed.emit(response_code, response)
		else: push_connection_error()
	else: push_connection_error()
	if remove_last_chat:
		chat_history.pop_back()

func push_connection_error() -> void:
	error_pushed.emit()
	if try_again_on_failed:
		GuideServer.push_message("Try to connect again", 0)
		request_ai()
	else:
		GuideServer.push_message("An error occurred while connecting to the AI model. Please try again.", 2)  









