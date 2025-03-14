extends Node

const SESSION_SAVE_PATH:= "res://Save/Sessions/"
const MISTAKES_SAVE_PATH:= "res://Save/Mistakes/"


func save_session(history: Array, data: Dictionary, file_path:= "") -> SessionsRes:
	var sessions_size = get_sessions_files().size()
	var save_path = (SESSION_SAVE_PATH + "session_%s.res" % sessions_size) if not file_path else file_path
	var session = SessionsRes.new()
	session.session_history = history
	session.user_name = data.user_name
	session.mother_language = data.mother_language
	session.learning_language = data.learning_language
	session.user_level = data.user_level
	session.ai_character = data.ai_character
	ResourceSaver.save(session, save_path)
	return ResourceLoader.load(save_path)

func load_sessions() -> Array[SessionsRes]:
	var resources: Array[SessionsRes]
	var sessions_filenames = get_sessions_files()
	for i in sessions_filenames:
		var i_path = SESSION_SAVE_PATH + i
		var res = ResourceLoader.load(i_path)
		if res is SessionsRes:
			resources.append(res)
	return resources

func save_mistake() -> void:
	pass

func load_mistakes() -> void:
	pass


func get_sessions_files() -> Array:
	return DirAccess.get_files_at(SESSION_SAVE_PATH)

func get_mistakes_files() -> Array:
	return DirAccess.get_files_at(MISTAKES_SAVE_PATH)







