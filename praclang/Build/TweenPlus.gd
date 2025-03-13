class_name TweenPlus extends Node



func tween(object: Object, property: NodePath, val_dur: Array[Array], ease: Tween.EaseType = 0, trans: Tween.TransitionType = 0) -> Tween:
	
	var t = create_tween().set_ease(ease).set_trans(trans)
	var final_values = val_dur[0]
	var durations = val_dur[1]
	var last_used_dur: float
	
	for index in final_values.size():
		var final_val = final_values[index]
		var dur = last_used_dur
		if durations.size() >= index+1:
			dur = durations[index]
		last_used_dur = dur
		t.tween_property(object, property, final_val, dur)
	
	t.play()
	
	return t

func on_finished(t: Tween, callable: Callable) -> void:
	t.finished.connect(callable)
