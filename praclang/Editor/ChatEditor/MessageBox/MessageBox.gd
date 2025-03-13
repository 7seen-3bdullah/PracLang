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
			var content_label = Label.new()
			content_label.set_text(content)
			content_box.add_child(content_label)
			box.add_child(content_box)
