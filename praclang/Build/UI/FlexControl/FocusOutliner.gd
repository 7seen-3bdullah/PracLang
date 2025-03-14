class_name FocusOutliner extends ColorRect

signal focus_changed(to: bool)

@export var _owner: FlexibleControl
@export var width: float = 2.0
@export var focus_color: Color = Color.WHITE

var focus_in: bool
func get_focus_in() -> bool:
	return focus_in
func set_focus_in(val: bool) -> void:
	focus_in = val


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var mouse_p = event.global_position
		var p = global_position
		var s = size
		var result = mouse_p.x > p.x && mouse_p.x < p.x + s.x && \
		mouse_p.y > p.y && mouse_p.y < p.y + s.y
		if focus_in != result:
			focus_in = result
			if _owner:
				_owner.focus_in = focus_in
			queue_redraw()


func _draw() -> void:
	if focus_in:
		draw_rect(Rect2(Vector2.ZERO, size), focus_color, false, width, true)
