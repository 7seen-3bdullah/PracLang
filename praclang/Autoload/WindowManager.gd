extends Node

const MAIN_WINDOW = preload("res://UI&UX/Window/MainWindow.tscn")

func popup_window(processing_node: Node, window_size:= Vector2i(300, 200), window_title:= "Window") -> Window:
	var window = MAIN_WINDOW.instantiate()
	var processing_rect = create_processing_rect()
	window.size = window_size
	window.title = window_title
	window.close_requested.connect(processing_rect.queue_free)
	processing_node.add_child(processing_rect)
	add_child(window)
	return window

func popup_borderless_window(processing_node: Control, window_size:= Vector2(300, 200), window_title:= "Window") -> Window:
	var window = popup_window(processing_node, window_size, window_title)
	window.borderless = true
	return window

func create_processing_rect() -> ColorRect:
	var rect = ProcessingControl.new()
	rect.color = Color(Color.BLACK, .5)
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	return rect
