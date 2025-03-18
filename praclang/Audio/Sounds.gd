extends Node


var keyboard_clicks = [
	preload("res://sounds/Keyboard/Keyboard_Click.ogg"),
	preload("res://sounds/Keyboard/Keyboard_Click_1.ogg"),
	preload("res://sounds/Keyboard/Keyboard_Click_2.ogg"),
	preload("res://sounds/Keyboard/Keyboard_Click_3.ogg"),
	preload("res://sounds/Keyboard/Keyboard_Click_4.ogg"),
	preload("res://sounds/Keyboard/Keyboard_Click_5.ogg"),
	preload("res://sounds/Keyboard/Keyboard_Click_6.ogg"),
	preload("res://sounds/Keyboard/Keyboard_Click_7.ogg"),
	preload("res://sounds/Keyboard/Keyboard_Click_8.ogg"),
	preload("res://sounds/Keyboard/Keyboard_Click_9.ogg"),
	preload("res://sounds/Keyboard/Keyboard_Click_10.ogg"),
	preload("res://sounds/Keyboard/Keyboard_Click_11.ogg"),
	preload("res://sounds/Keyboard/Keyboard_Click_12.ogg"),
	preload("res://sounds/Keyboard/Keyboard_Click_13.ogg"),
	preload("res://sounds/Keyboard/Keyboard_Click_14.ogg"),
	preload("res://sounds/Keyboard/Keyboard_Click_15.ogg"),
	preload("res://sounds/Keyboard/Keyboard_Click_16.ogg"),
	preload("res://sounds/Keyboard/Keyboard_Click_17.ogg"),
	preload("res://sounds/Keyboard/Keyboard_Click_18.ogg"),
	preload("res://sounds/Keyboard/Keyboard_Click_19.ogg"),
	preload("res://sounds/Keyboard/Keyboard_Click_20.ogg"),
	preload("res://sounds/Keyboard/Keyboard_Click_21.ogg"),
	]


const CLICK = preload("res://sounds/click/Fightstick_Click.ogg")

const user_send = preload("res://sounds/Send/bubble-pop.ogg")
const ai_send = preload("res://sounds/Send/bubble_iMw0wu6.ogg")

const ERROR_1 = preload("res://sounds/errors/error1.ogg")
const ERROR_2 = preload("res://sounds/errors/error2.ogg")


# -------------------------------


func Click_Sound(pitch_scale:float, volume:float):
	var audio_player_click = AudioStreamPlayer.new()
	add_child(audio_player_click)
	
	audio_player_click.pitch_scale = pitch_scale
	audio_player_click.volume_db = volume
	
	audio_player_click.stream = CLICK
	audio_player_click.play()
	
	await  audio_player_click.finished
	audio_player_click.queue_free()


# -------------------------------


func Send_Message_Sound(pitch_scale:float, volume :float):
	var audio_player_send = AudioStreamPlayer.new()
	add_child(audio_player_send)
	
	audio_player_send.volume_db = volume
	audio_player_send.pitch_scale = pitch_scale
	audio_player_send.stream = ai_send
	
	audio_player_send.play()
	await audio_player_send.finished
	audio_player_send.queue_free()



# -------------------------------


func Typing_Sound(volume :float= -10):
	var sound = keyboard_clicks[randi_range(0,21)]
	
	var audio_player_typing = AudioStreamPlayer.new()
	add_child(audio_player_typing)
	
	audio_player_typing.volume_db = volume
	
	
	audio_player_typing.stream = sound
	audio_player_typing.play()
	
	await audio_player_typing.finished
	audio_player_typing.queue_free()


# -------------------------------


func Error_sound(errortype:String):
	var audio_player_error = AudioStreamPlayer.new()
	add_child(audio_player_error)
	
	if errortype == "error":
		audio_player_error.stream = ERROR_1
	elif errortype == "mistake":
		audio_player_error.stream = ERROR_2
	
	audio_player_error.volume_db = -5
	audio_player_error.play()
	
	await audio_player_error.finished
	audio_player_error.queue_free()
