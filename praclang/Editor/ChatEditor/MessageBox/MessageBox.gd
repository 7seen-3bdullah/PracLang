extends PanelContainer

@onready var role_rect: ColorRect = %RoleRect
@onready var role_label: Label = %RoleLabel
@onready var box: VBoxContainer = %Box


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
			var content_label = Label.new()
			content_label.text = content
			content_label.autowrap_mode = TextServer.AUTOWRAP_WORD
			content_margin.add_theme_constant_override("margin_left", 4)
			content_margin.add_theme_constant_override("margin_top", 4)
			content_margin.add_theme_constant_override("margin_right", 4)
			content_margin.add_theme_constant_override("margin_bottom", 4)
			content_box.custom_minimum_size = Vector2.ONE * 80.0
			content_margin.add_child(content_label)
			content_box.add_child(content_margin)
			box.add_child(content_box)
