extends Node

const SESSION_SAVE_PATH:= "res://Save/Sessions/"
const MISTAKES_SAVE_PATH:= "res://Save/Mistakes/"




func save_session(history: Array, data: Dictionary, completions = null, file_path:= "", file_name:= "") -> SessionsRes:
	var sessions_filenames = get_sessions_filenames()
	var save_path = (SESSION_SAVE_PATH + file_name + ".res") if not file_path else file_path
	var session_res = SessionsRes.new()
	session_res.session_history = history
	if completions != null:
		session_res.completions = completions
	session_res.user_name = data.user_name
	session_res.mother_language = data.mother_language
	session_res.learning_language = data.learning_language
	session_res.user_level = data.user_level
	session_res.ai_character = data.ai_character
	ResourceSaver.save(session_res, save_path)
	return ResourceLoader.load(save_path)

func load_session(path: String) -> SessionsRes:
	return ResourceLoader.load(path)

func load_sessions() -> Array[SessionsRes]:
	var sessions_filenames = get_sessions_filenames()
	var resources: Array[SessionsRes]
	for i in sessions_filenames:
		var i_path = SESSION_SAVE_PATH + i
		var res = ResourceLoader.load(i_path)
		if res is SessionsRes:
			resources.append(res)
	return resources

func delete_session(path: String) -> void:
	DirAccess.remove_absolute(path)





func save_mistake(mistake: String, type: int, mistakes_filenames: Array, language_for: String) -> void:
	var save_path = MISTAKES_SAVE_PATH + language_for + "/" + generate_file_name(mistakes_filenames, "mistake_") + ".res"
	var mistake_res = MistakeRes.new()
	mistake_res.mistake = mistake
	mistake_res.type = type
	ResourceSaver.save(mistake_res, save_path)

func save_mistakes(mistakes: Array, notes: Array, language_for: String) -> void:
	var mistakes_filenames = get_mistakes_files(language_for)
	for mistake in mistakes:
		save_mistake(mistake, 0, mistakes_filenames, language_for)
	for note in notes:
		save_mistake(note, 1, mistakes_filenames, language_for)


func load_mistakes(language_for: String) -> Array[MistakeRes]:
	var mistakes_filenames = get_mistakes_files(language_for)
	var resources: Array[MistakeRes]
	for i in mistakes_filenames:
		var i_path = MISTAKES_SAVE_PATH + language_for + "/" + i
		var res = ResourceLoader.load(i_path)
		if res is MistakeRes:
			resources.append(res)
	return resources

func delete_mistake(mistake_path: String) -> void:
	DirAccess.remove_absolute(mistake_path)

func make_mistake_dir_absolute(language_for: String) -> void:
	DirAccess.make_dir_absolute(MISTAKES_SAVE_PATH + language_for)






func get_sessions_filenames() -> Array:
	return DirAccess.get_files_at(SESSION_SAVE_PATH)

func get_mistakes_files(language_for: String) -> Array:
	return DirAccess.get_files_at(MISTAKES_SAVE_PATH + language_for)






func generate_file_name(old_files: Array, file_custom_preffix:= "") -> String:
	var new_file_name: String
	while old_files.has(new_file_name) or not new_file_name:
		new_file_name = str(file_custom_preffix, random_characters(10))
	return new_file_name

func random_characters(length: int) -> String:
	var characters: String = ""
	var possible_chars: String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	for i in length:
		var random_index = randi() % possible_chars.length()
		characters += possible_chars[random_index]
	return characters
