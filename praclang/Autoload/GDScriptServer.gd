extends Node

const LANG_NAME:= "GDScript"
const LANG_EXTENSION:= "gd"

var keys:= {
	"keyword": [
		"extends", "class_name", "class", "var", "const",
		"static", "func", "and", "or", "in", "is", "not", "as",
		"breakpoint", "await", "signal", "enum", "self", "super"
	],
	"method": [
		"if", "elif", "else", "while", "for", "match",
		"pass", "break", "continue", "return"
	],
	"class built-in": ClassDB.get_class_list(),
	"type built-in": [
		"AABB", "Array", "Basis", "bool", "Callable", "Color",
		"Dictionary", "float", "int", "NodePath", "Plane", "Projection",
		"Quaternion", "Rect2", "Rect2i", "RID", "Signal", "String", "StringName",
		"Transform2D", "Transform3D", "Variant", "Vector2", "Vector2i",
		"Vector3", "Vector3i", "Vector4", "Vector4i", "void"
	]
}

