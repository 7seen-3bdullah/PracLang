extends Node

func squish(object, scale:Vector2, time:float):
	var tween = create_tween().set_parallel(true)
	
	tween.tween_property(object, "scale", Vector2(scale.x, scale.y), time).set_ease(Tween.EASE_IN)
	tween.chain()
	tween.tween_property(object, "scale", Vector2(1, 1), time).set_ease(Tween.EASE_OUT)



func shake(object, power:float, time:float):
	var last_pos = object.position
	if object is Control:
		object.add_theme_color_override("font_placeholder_color",Color(1.0, 0.0, 0.0))
	
	var tween = create_tween().set_ease(Tween.EASE_IN)
	tween.tween_property(object, "position.x", Vector2(power, last_pos.y), time)
	tween.chain()
	tween.tween_property(object, "position", Vector2(-power, last_pos.y), time)
	tween.chain()
	tween.tween_property(object, "position", Vector2(power, last_pos.y), time)
	tween.chain()
	tween.tween_property(object, "position", last_pos, time)
	
	if object is Control:
		await tween.finished
		await get_tree().create_timer(0.1).timeout
		object.add_theme_color_override("font_placeholder_color",Color(1.0, 1.0, 1.0))










