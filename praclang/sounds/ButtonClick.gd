extends Node

# -------------------------------
#اسماء النود الي ضفت لها السكربت
#NewSessionButton
#CollapseButton
# -------------------------------


# -------------------------------
#NewSessionButton

func _on_button_up() -> void:
	Sounds.Click_Sound(1,-5)
# ---
func _on_mouse_entered() -> void:
	Sounds.Click_Sound(2,-15)


# -------------------------------
#CollapseButton

func _on_collapse_button_button_up() -> void:
	Sounds.Click_Sound(1,-5)
# ---
func _on_collapse_button_mouse_entered() -> void:
	Sounds.Click_Sound(2,-15)


# -------------------------------
