extends Node2D

#author: Pixelbyte Studios

const VOL_OFF_DB = -80

export (float) var music_volume_db = 0.0
export (float) var ambient_volume_db = 0.0
export (String, DIR) var music_folder = "music"

var paused:bool setget , get_paused
var playing:bool setget ,get_playing
var ambient_playing:bool setget ,get_ambient_playing
var ambient_paused:bool setget ,get_ambient_paused

onready var music:Dictionary = {"pausing" : false, "current" : $MusicA, "A": $MusicA,"B": $MusicB }
onready var ambient:Dictionary = {"pausing" : false, "current" : $Ambient, "A": $Ambient,"B": $AmbientB }

func get_paused(): return music.current.stream != null && music.current.stream_paused
func get_playing(): return music.current.stream != null && music.current.playing
func get_ambient_playing(): return ambient.current.stream != null && ambient.current.playing
func get_ambient_paused(): return ambient.current.stream != null && ambient.current.stream_paused
	
func _swap(dic:Dictionary):
	if dic.current == dic.A: dic.current = dic.B
	else: dic.current = dic.A

func _music_res(filename:String) -> String:
	if not music_folder.ends_with("/"):
		music_folder += "/"
	return 	music_folder + filename

func play(filename, fade_time: float = 0):
	_play(filename, music,music_volume_db, fade_time)
func play_ambient(filename:String, fade_time:float = 0):
	_play(filename, ambient, ambient_volume_db, fade_time)
func _play(filename, dic:Dictionary, final_vol_db:float, fade_time: float = 0):
	var filepath:String = _music_res(filename)
	var audio_stream = load(filepath)
	if audio_stream == null:
		printerr("Unable to find file: %s" % filepath)
		return

	if dic.current.stream == audio_stream:
		if dic.current.stream_paused:
			dic.current.stream_paused = false
		elif !dic.current.playing:
			dic.current.volume_db = final_vol_db
			dic.current.play()
		return
	
	var _cross_fade:bool
	if !dic.current.stream_paused && dic.current.playing && fade_time > 0 && dic.current.get_playback_position() > 0:
		var tw:Tween = dic.current.get_node("Tween")
		tw.remove_all()
		tw.interpolate_property(dic.current, "volume_db", dic.current.volume_db, VOL_OFF_DB, fade_time, Tween.TRANS_QUAD, Tween.EASE_IN)
		tw.start()
		_cross_fade = true
		_swap(dic)

	dic.current.stream = audio_stream
	dic.current.stream_paused = false
	
	if _cross_fade || fade_time > 0:
		dic.current.volume_db = VOL_OFF_DB
		var tw = dic.current.get_node("Tween")
		tw.remove_all()
		tw.interpolate_property(dic.current, "volume_db", VOL_OFF_DB, final_vol_db, fade_time, Tween.TRANS_QUAD, Tween.EASE_OUT)	
		tw.start()
	else:
		dic.current.volume_db = final_vol_db
	dic.current.play()

func stop(fade_time:float = 0):
	_stop(music, fade_time)
func stop_ambient(fade_time:float = 0):
	_stop(ambient, fade_time)
func _stop(dic:Dictionary,fade_time:float = 0):
	if !dic.current.playing:
		return

	if fade_time > 0:
		var tw:Tween = dic.current.get_node("Tween")
		var nc = dic.current
		_swap(dic)
		tw.remove_all()
		tw.interpolate_property(nc, "volume_db", nc.volume_db, VOL_OFF_DB, fade_time, Tween.TRANS_SINE, Tween.EASE_IN)
		tw.start()
	else:
		dic.A.stop()
		dic.B.stop()
		dic.current.stream_paused = false

func pause(fade_time:float = 0):
	_pause(music, fade_time)
func _pause(dic:Dictionary, fade_time:float = 0):
	if !dic.current.playing:
		return

	var tw = dic.current.get_node("Tween")
	tw.remove_all()
	
	if fade_time > 0:
		dic.pausing = true
		tw.interpolate_property(dic.current, "volume_db", dic.current.volume_db, VOL_OFF_DB, fade_time, Tween.TRANS_SINE, Tween.EASE_IN)
		tw.start()
	else:
		dic.current.stream_paused = true

func resume(fade_time:float = 0):
	_resume(music, music_volume_db, fade_time)
func resume_ambient(fade_time:float = 0):
	_resume(ambient, ambient_volume_db, fade_time)
func _resume(dic:Dictionary, volume_db:float, fade_time:float = 0):
	if !get_paused() && !dic.pausing: 
		return
	
	var tw:Tween = dic.current.get_node("Tween")
	tw.remove_all()

	dic.pausing = false
	dic.current.stream_paused = false
	
	if fade_time > 0:
		tw.interpolate_property(dic.current, "volume_db", dic.current.volume_db, volume_db, fade_time, Tween.TRANS_QUAD, Tween.EASE_OUT)
		tw.start()
	else:
		dic.current.volume_db = volume_db
		
func replay(fade_time:float = 0):
	_replay(music, music_volume_db, fade_time)
#func replay_ambient(fade_time:float = 0):
#	_replay(ambient, ambient_volume_db, fade_time)
func _replay(dic:Dictionary, vol_db:float, fade_time:float = 0):
	if dic.current.stream == null || dic.current.playing:
		return
	
	#otherwise, swap in our previous stream and turn it back on
	_swap(dic)

	var tw = dic.current.get_node("Tween")
	tw.remove_all()
	if fade_time > 0:
		tw.interpolate_property(dic.current, "volume_db", VOL_OFF_DB, vol_db, fade_time, Tween.TRANS_QUAD, Tween.EASE_OUT)
		tw.start()
	else:
		dic.current.volume_db = music_volume_db
	dic.current.play()

func _on_MusicA_tween_completed(object, key):
	if $MusicA.volume_db == VOL_OFF_DB:
		if music.pausing:
			$MusicA.stream_paused = true
		else:
			$MusicA.stop()
			$MusicA.stream_paused = false

func _on_MusicB_tween_completed(object, key):
	if $MusicB.volume_db == VOL_OFF_DB:
		if music.pausing:
			$MusicB.stream_paused = true
		else:
			$MusicB.stop()
			$MusicB.stream_paused = false

func _on_Ambient_tween_completed(object, key):
	if $Ambient.volume_db == VOL_OFF_DB:
		if ambient.pausing:
			$Ambient.stream_paused = true
		else:
			$Ambient.stop()
			$Ambient.stream_paused = false

func _on_AmbientB_tween_completed(object, key):
	if $AmbientB.volume_db == VOL_OFF_DB:
		if ambient.pausing:
			$AmbientB.stream_paused = true
		else:
			$AmbientB.stop()
			$AmbientB.stream_paused = false

