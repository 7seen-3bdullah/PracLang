extends ShortcutNode

@onready var chat_box: Control = $".."

func _ready() -> void:
	super()
	create_key_shortcut(NONE_MASK, KEY_ENTER, chat_box.send_message)


