extends Node

func Scosh(node, scale:Vector2, time:float):
	var tween = create_tween().set_parallel(true)
	
	tween.tween_property(node, "scale", Vector2(scale.x, scale.y), time).set_ease(Tween.EASE_IN)
	tween.chain()
	tween.tween_property(node, "scale", Vector2(1, 1), time).set_ease(Tween.EASE_OUT)


func BOB(node):
	pass


func Shacke(node, power:float, time:float):
	var last_pos = node.position
	if node is Control:
		node.add_theme_color_override("font_placeholder_color",Color(1.0, 0.0, 0.0))
	
	var tween = create_tween().set_ease(Tween.EASE_IN)
	tween.tween_property(node, "position.x", Vector2(power, last_pos.y), time)
	tween.chain()
	tween.tween_property(node, "position", Vector2(-power, last_pos.y), time)
	tween.chain()
	tween.tween_property(node, "position", Vector2(power, last_pos.y), time)
	tween.chain()
	tween.tween_property(node, "position", last_pos, time)
	
	
	if node is Control:
		await tween.finished
		await get_tree().create_timer(0.1).timeout
		node.add_theme_color_override("font_placeholder_color",Color(1.0, 1.0, 1.0))
