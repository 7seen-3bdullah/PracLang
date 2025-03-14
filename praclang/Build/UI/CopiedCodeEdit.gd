class_name CopiedCodeEdit extends CodeEdit


func _ready() -> void:
	mouse_entered.connect(on_mouse_entered)
	mouse_exited.connect(on_mouse_exited)

func on_mouse_entered() -> void:
	pass

func on_mouse_exited() -> void:
	pass
