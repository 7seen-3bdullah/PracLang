class_name FocusOutliner extends ColorRect

@export var _owner: FlexibleControl
@export var width: float = 2.0
@export var focus_color: Color = Color.WHITE

func _ready() -> void:
	_owner.focus_changed.connect(on_focus_changed)

func on_focus_changed(to: bool) -> void:
	queue_redraw()

func _draw() -> void:
	if _owner.focus_in:
		draw_rect(Rect2(Vector2.ZERO, size), focus_color, false, width, true)
