extends Node

var startshake := true

func squish(object, scale:Vector2, time:float):
	var tween = create_tween().set_parallel(true)
	
	tween.tween_property(object, "scale", Vector2(scale.x, scale.y), time).set_ease(Tween.EASE_IN)
	tween.chain()
	tween.tween_property(object, "scale", Vector2(1, 1), time).set_ease(Tween.EASE_OUT)



func shake(object, power: float, time: float):
	if startshake:
		startshake = false
		
		var last_pos = object.position
		if object is Control:
			object.add_theme_color_override("font_placeholder_color", Color(1.0, 0.0, 0.0))
		
		var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		
		var shake_points = [
			Vector2(power, 0),
			Vector2(-power, 0),
			Vector2(power/2, 0),
			Vector2(-power/2, 0),
			Vector2.ZERO
		]
		for point in shake_points:
			tween.tween_property(object, "position", last_pos + point, time * 0.3)
			tween.chain()
		if object is Control:
			await tween.finished
			object.remove_theme_color_override("font_placeholder_color")
			startshake = true
