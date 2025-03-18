extends Control


func _ready() -> void:
	var window_size = Vector2i(1600, 700)
	get_window().size = window_size
	get_window().position = (DisplayServer.screen_get_size(0) - window_size) / 2
	get_window().borderless = false
