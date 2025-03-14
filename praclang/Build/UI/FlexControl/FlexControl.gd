class_name FlexibleControl extends Control


signal focus_changed(to: bool)


var shortcuts: Dictionary

var focus_in: bool:
	set(val):
		focus_in = val
		focus_changed.emit(val)

const DIST_TO_CORNER = 10
const DRAG_LENGTH = 20

enum Corners {None, LeftUp}
var corner: Corners

var drag_from: Variant
var splited: bool

var curr_cntnr: SplitContainer
var	copy: Control
var self_scene: Variant



@export var test: bool
@export var enabled: bool










func _ready() -> void:
	flexControl_setup()

func flexControl_setup():
	self_scene = load(scene_file_path)







func _input(event: InputEvent) -> void:
	if enabled:
		flexControl_input(event)


func flexControl_input(event: InputEvent) -> void:
	
	if event is InputEventMouse:
		
		var mouse_pos = event.global_position
		
		if event is InputEventMouseButton:
			match event.button_index:
				1:
					if event.is_pressed():
						if corner:
							drag_from = mouse_pos
					elif event.is_released():
						drag_from = null
						if splited:
							copy.queue_free()
							reparent(curr_cntnr)
							show()
						splited = false
				2:
					if corner && event.is_released():
						erase()
		
		if event is InputEventMouseMotion:
			
			if drag_from:
				if !splited:
					if !is_approch(mouse_pos, drag_from, DRAG_LENGTH):
						var dtd = mouse_pos - drag_from # distance to dragFrom
						split(dtd.x < dtd.y)
						splited = true
				else:
					var split_offset = (mouse_pos - drag_from)
					curr_cntnr.split_offset = split_offset.y if curr_cntnr.vertical else split_offset.x
				return
			
			var pos = global_position
			if is_approch(mouse_pos, pos): corner = Corners.LeftUp
			else: corner = Corners.None
			mouse_default_cursor_shape = Control.CURSOR_CROSS if corner else Control.CURSOR_ARROW
	
	if event.is_pressed():
		if focus_in:
			for i in shortcuts:
				if event.is_action_pressed(i):
					shortcuts.get(i).call()



func split(vertical: bool) -> void:
	var cntnr = SplitContainer.new()
	cntnr.vertical = vertical
	cntnr.layout_mode = 1
	cntnr.anchors_preset = PRESET_FULL_RECT
	cntnr.add_theme_constant_override("separation", 0)
	
	if test:
			var c = duplicate(); c.get_node("ColorRect").color = Color(
				randf_range(.0, 1.0), randf_range(.0, 1.0), randf_range(.0, 1.0)
			)
			cntnr.add_child(c)
	else:
		cntnr.add_child(self_scene.instantiate())
	var duplicated = duplicate()
	duplicated.process_mode = Node.PROCESS_MODE_DISABLED
	cntnr.add_child(duplicated)
	copy = duplicated
	
	get_parent().add_child(cntnr)
	get_parent().move_child(cntnr, get_index())
	hide()
	
	curr_cntnr = cntnr


func erase() -> void:
	var p = get_parent()
	var order = p.get_index()
	if p is SplitContainer:
		var neigbor_control
		for i in p.get_children():
			if i != self:
				neigbor_control = i.duplicate()
		p.get_parent().add_child(neigbor_control)
		p.get_parent().move_child(neigbor_control, order)
		p.queue_free()






func is_approch(from: Vector2, to: Vector2, dist:= DIST_TO_CORNER) -> bool:
	return from.distance_to(to) < dist && focus_in
