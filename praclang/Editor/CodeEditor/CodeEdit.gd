class_name AppCodeEdit extends CodeEdit

@export_group(&"Syntax Theme")
@export var number_color:= Color("E0A96D")  # برتقالي فاتح دافئ للأرقام
@export var symbol_color:= Color("63C5CD")  # أزرق سماوي هادئ للرموز
@export var function_color:= Color("74A8E8")  # أزرق مهدئ للدوال
@export var member_variable_color:= Color("E8D28B")  # ذهبي فاتح ناعم للمتغيرات الخاصة
@export var language_key_color:= Color("B68BD8")  # بنفسجي هادئ للكلمات المفتاحية
@export var language_method_color:= Color("D4747C")  # أحمر وردي دافئ للدوال المدمجة
@export var language_builtInClass_color:= Color("88D1B2")  # أخضر مائل للأزرق لأنواع البيانات المدمجة
@export var language_builtInType_color:= Color("A0D2A6")  # أخضر فاتح ناعم لأنواع البيانات
@export var string_color:= Color("A3CF8C")  # أخضر عشبي للنصوص
@export var tool_color:= Color("71A55B")
@export var command_color:= Color("5F5F5F") # رمادي هادئ


func _ready() -> void:
	update_highlighter(GdScriptServer.keys)



func update_highlighter(Lang_keys: Dictionary) -> void:
	var h = CodeHighlighter.new()
	var lang_keywords = Lang_keys["keyword"]
	var lang_methods = Lang_keys["method"]
	var class_builtIn = Lang_keys["class built-in"]
	var type_builtIn = Lang_keys["type built-in"]
	h.set_number_color(number_color)
	h.set_symbol_color(symbol_color)
	h.set_function_color(function_color)
	h.set_member_variable_color(member_variable_color)
	for key in lang_keywords:
		h.add_keyword_color(key, language_key_color)
	for method in lang_methods:
		h.add_keyword_color(method, language_method_color)
	for _class in class_builtIn:
		h.add_keyword_color(_class, language_builtInClass_color)
	for type in type_builtIn:
		h.add_keyword_color(type, language_builtInType_color)
	h.add_color_region("'", "'", string_color)
	h.add_color_region('"', '"', string_color)
	h.add_color_region("@", " ", tool_color)
	h.add_color_region("#", "", command_color)
	syntax_highlighter = h
