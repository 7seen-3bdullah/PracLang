extends PanelContainer


@onready var role_rect: ColorRect = %RoleRect
@onready var role_label: Label = %RoleLabel
@onready var box: VBoxContainer = %Box
@onready var split: HSplitContainer = %Split
@onready var panel: PanelContainer = %Panel

@onready var tween: TweenPlus = %TweenPlus

var initial_color: Color

const CONTENT_PREVIEW = preload("res://UI&UX/ContentPreview.tscn")


func _ready() -> void:
	tween.tween(split, "position:y", [[50.0, .0], [.0, .4]], Tween.EASE_OUT, Tween.TRANS_QUAD)
	tween.tween(self, "modulate:a", [[.0, 1.0], [.0, .4]], Tween.EASE_OUT, Tween.TRANS_QUAD)
	mouse_entered.connect(on_mouse_entered)
	mouse_exited.connect(on_mouse_exited)

func on_mouse_entered() -> void:
	tween_pos_and_color(Vector2(20, 0), initial_color.lightened(.2))
	%HoverAudio.play()
func on_mouse_exited() -> void:
	tween_pos_and_color(Vector2.ZERO, initial_color)

func tween_pos_and_color(pos: Vector2, color: Color) -> void:
	var panel_style = panel.get_theme_stylebox("panel")
	tween.tween(split, "position", [[pos], [.4]], Tween.EASE_OUT, Tween.TRANS_QUAD)
	tween.tween(panel_style, "bg_color", [[color], [.2]])


func setup(panel_style: StyleBox, role_color: Color, role_name: String, messages_content: Array) -> void:
	
	panel.add_theme_stylebox_override("panel", panel_style.duplicate())
	role_rect.color = role_color
	role_label.text = role_name
	
	for index in messages_content.size():
		
		var message_data = messages_content[index]
		var key = message_data.keys()[0]
		var text = message_data.text
		
		var content_box = PanelContainer.new()
		var content_margin = MarginContainer.new()
		var hsplit = HSplitContainer.new()
		var content_preview = CONTENT_PREVIEW.instantiate()
		
		content_preview.text = text
		hsplit.set_dragging_enabled(false)
		content_margin.add_theme_constant_override("margin_left", 4)
		content_margin.add_theme_constant_override("margin_top", 4)
		content_margin.add_theme_constant_override("margin_right", 4)
		content_margin.add_theme_constant_override("margin_bottom", 4)
		content_box.custom_minimum_size = Vector2(150.0, 100.0)
		content_box.mouse_filter = Control.MOUSE_FILTER_PASS
		
		if message_data.has("title"):
			var title = message_data.title
			var title_label = Label.new()
			title_label.set_text(title)
			title_label.add_theme_font_size_override("font_size", 20)
			title_label.mouse_filter = Control.MOUSE_FILTER_PASS
			box.add_child(title_label)
		if message_data.has("custom_color"):
			var custom_color = message_data.custom_color
			var custom_color_rect = ColorRect.new()
			var style = StyleBoxFlat.new()
			style.set_bg_color(Color(custom_color.darkened(.6), .5))
			content_box.add_theme_stylebox_override("panel", style)
			custom_color_rect.set_color(custom_color)
			custom_color_rect.set_custom_minimum_size(Vector2.RIGHT*4)
			hsplit.add_child(custom_color_rect)
		
		hsplit.add_child(content_preview)
		content_margin.add_child(hsplit)
		content_box.add_child(content_margin)
		box.add_child(content_box)
	initial_color = panel.get_theme_stylebox("panel").bg_color



