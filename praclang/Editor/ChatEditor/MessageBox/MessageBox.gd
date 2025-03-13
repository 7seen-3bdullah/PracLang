extends PanelContainer


@onready var role_rect: ColorRect = %RoleRect
@onready var role_label: Label = %RoleLabel
@onready var box: VBoxContainer = %Box
@onready var split: HSplitContainer = %Split

@onready var tween: TweenPlus = %TweenPlus


const MESSAGE_PREVIEW = preload("res://UI&UX/MessagePreview.tscn")

func setup(panel_style: StyleBox, role_color: Color, role_name: String,
	messages_content: Array) -> void:
		self.add_theme_stylebox_override("panel", panel_style)
		role_rect.color = role_color
		role_label.text = role_name
		for index in messages_content.size():
			var key = messages_content[index].keys()[0]
			var content = messages_content[index].values()[0]
			var content_box = PanelContainer.new()
			var content_margin = MarginContainer.new()
			var content_preview = MESSAGE_PREVIEW.instantiate()
			content_preview.text = content
			content_preview.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			content_margin.add_theme_constant_override("margin_left", 4)
			content_margin.add_theme_constant_override("margin_top", 4)
			content_margin.add_theme_constant_override("margin_right", 4)
			content_margin.add_theme_constant_override("margin_bottom", 4)
			content_box.custom_minimum_size = Vector2(150.0, 100.0)
			content_margin.add_child(content_preview)
			content_box.add_child(content_margin)
			box.add_child(content_box)


func _ready() -> void:
	tween.tween(split, "position:y", [[10.0, .0], [.0, .2]], Tween.EASE_OUT, Tween.TRANS_QUAD)









