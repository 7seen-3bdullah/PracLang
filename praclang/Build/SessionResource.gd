class_name SessionsRes extends Resource


@export var session_history: Array

@export var user_name: String
@export var mother_language: String
@export var learning_language: String
@export var user_level: String
@export var ai_character: String

const B:= Color.SADDLE_BROWN
const S:= Color.SILVER
const G:= Color.GOLDENROD
const D:= Color.MEDIUM_AQUAMARINE

@export var completions: Dictionary[int, Dictionary] = {
	0: {"completed": .0, "color": B},
	1: {"completed": .0, "color": B},
	2: {"completed": .0, "color": S},
	3: {"completed": .0, "color": S},
	4: {"completed": .0, "color": G},
	5: {"completed": .0, "color": G},
	6: {"completed": .0, "color": D},
	7: {"completed": .0, "color": D},
}

@export var level_up_speed:= 50.0


