class_name AIInterface extends Node

signal result_pushed(error: int, response: Dictionary)

@export var use_history:= true
var chat_history: Array[Dictionary] = []

@onready var http_request = HTTPRequest.new()

const API_URL = "https://openrouter.ai/api/v1/chat/completions"
const API_KEY = "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"



func _ready() -> void:
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)

func send_message(message: String) -> void:
	chat_history.append({"role": "user", "content": [{"type": "text", "text": message}]})
	var headers = [
		"Authorization: Bearer " + API_KEY,
		"Content-Type: application/json"
	]
	
	var body = {
		"model": "google/gemini-2.0-pro-exp-02-05:free",
		"messages": chat_history
	}
	
	var json_body = JSON.stringify(body)
	var error = http_request.request(API_URL, headers, HTTPClient.METHOD_POST, json_body)
	
	if error != OK:
		print_connection_error()
	
	if not use_history:
		chat_history.clear()

func _on_request_completed(result, response_code, headers, body) -> void:
	if response_code == 200:
		var response = JSON.parse_string(body.get_string_from_utf8())
		if response.size():
			if use_history:
				chat_history.append(response["choices"][0]["message"])
			push_result(response_code, response)
		else: print_connection_error()
	else: print_connection_error()


func push_result(error: int, response:= {}) -> void:
	result_pushed.emit(error, response)

func print_connection_error() -> void:
	GuideServer.push_message("An error occurred while connecting to the AI model. Please try again.", 2)  



