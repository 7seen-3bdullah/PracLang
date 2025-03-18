extends Node

const GUIDE_GROUP:= &"editor_guide"
const MESSAGE_GROUP:= &"editor_message"

const ERR_STRENGTH_COLORS:= [
	Color.WEB_GRAY,
	Color.PALE_GOLDENROD,
	Color.INDIAN_RED
]

var message_history: Array[Dictionary]

func push_guides(guides: Array[Dictionary] = []) -> void:
	if not guides:
		guides = [
			{"": "PracLang is a program for learning natural languages through an engaging conversation with artificial intelligence."}
		]
	var result_guide: String
	var guide_labels = get_tree().get_nodes_in_group(GUIDE_GROUP)
	for index in guides.size():
		var guide = guides[index]
		var guide_key = guide.keys()[0]
		var guide_val = guide.values()[0]
		if index:
			result_guide += "   |   "
		if guide_key:
			result_guide += str(guide_key, " : ")
		result_guide += guide_val
	set_labels_text(guide_labels, result_guide, 0)

func push_message(message: String, error_strength: int) -> void:
	var message_labels = get_tree().get_nodes_in_group(MESSAGE_GROUP)
	message_history.append({
		"message": message,
		"error_strength": error_strength
	})
	set_labels_text(message_labels, message, error_strength)


func set_labels_text(labels: Array, text: String, color_index: int, while_loop = null) -> void:
	for label: Label in labels:
		if label is NotificationLabel:
			label.set_notification_text(text)
		else:
			label.set_text(text)
		label.add_theme_color_override("font_color", ERR_STRENGTH_COLORS[color_index])
		if while_loop:
			while_loop.call(label)








