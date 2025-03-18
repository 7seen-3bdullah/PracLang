extends PanelContainer

@export var completion_texture: Texture2D

@onready var box: HBoxContainer = %Box
@onready var count_label: Label = %CountLabel
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var completed_image: TextureRect = %CompletedImage
@onready var star: TextureRect = %Star
@onready var tween: TweenPlus = %TweenPlus

const CORRECT_SELECTED = preload("res://UI&UX/Style/CorrectSelected.tres")
const NORMAL_SELECTED = preload("res://UI&UX/Style/NormalSelected.tres")

var completed: float:
	set(val):
		completed = val
		tween.tween(progress_bar, "value", [[val], [.4]])
var current: bool:
	set(val):
		current = val
		if val:
			add_theme_stylebox_override("panel", NORMAL_SELECTED.duplicate(true))

func _ready() -> void:
	tween.tween(box, "position:x", [[-40.0, .0], [.0, .4]])
	tween.tween(box, "modulate:a", [[.0, 1.0], [.0, 1.0]])

func setup(_count: int, completion: float, star_color: Color, _current:= false) -> void:
	current = _current
	star.modulate = star_color
	count_label.text = str(_count)
	change_completion(completion)

func change_completion(to: float) -> void:
	update_completion(to)

func append_completion(append: float) -> void:
	var result_value = completed + append
	update_completion(result_value)

func get_completion() -> float:
	return completed

func update_completion(to: float) -> void:
	completed = to
	if completed >= 100.0:
		completed_image.texture = completion_texture
		add_theme_stylebox_override("panel", CORRECT_SELECTED.duplicate(true))
	elif current:
		add_theme_stylebox_override("panel", NORMAL_SELECTED.duplicate(true))

func notificate(color: Color) -> void:
	var style = get_theme_stylebox("panel")
	var bg_color = style.bg_color
	tween.tween(style, "bg_color", [[color, bg_color], [.1, .5]])









