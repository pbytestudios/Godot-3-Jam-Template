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
var music_name:String setget ,get_music_name
var ambient_name:String setget ,get_ambient_name

var music_mgr :FadeStreamMgr = FadeStreamMgr.new()
var ambient_mgr :FadeStreamMgr = FadeStreamMgr.new()

func _ready():
	music_mgr.add_players([$MusicA, $MusicB])
	ambient_mgr.add_players([$AmbientA, $AmbientB])
	music_mgr.music_folder = music_folder
	ambient_mgr.music_folder = music_folder
	music_mgr.fade_to_pause = true
	ambient_mgr.fade_to_pause = true

func get_paused() -> bool: return music_mgr.player.stream_paused if music_mgr.player_valid else false
func get_playing()-> bool: return music_mgr.player_valid && music_mgr.player.playing
func get_ambient_playing() -> bool: return ambient_mgr.player_valid && ambient_mgr.player.playing
func get_ambient_paused() -> bool: return ambient_mgr.player.stream_paused if ambient_mgr.player_valid else false
func get_music_name() -> String: return music_mgr.filename
func get_ambient_name() -> String: return ambient_mgr.filename
	
func play(filename, fade_time: float = 0):
	music_mgr.play(filename, music_volume_db, fade_time)
	
func play_ambient(filename:String, fade_time:float = 0):
	ambient_mgr.play(filename, ambient_volume_db, fade_time)

func stop(fade_time:float = 0):
	if music_mgr.player_valid:
		music_mgr.player.fade_stop(VOL_OFF_DB, fade_time)

func stop_ambient(fade_time:float = 0):
	if ambient_mgr.player_valid:
		ambient_mgr.player.fade_stop(VOL_OFF_DB, fade_time)

func pause(fade_time:float = 0):
	if music_mgr.player_valid:
		music_mgr.player.fade_pause(VOL_OFF_DB, fade_time)
		
func pause_ambient(fade_time:float = 0):
	if ambient_mgr.player_valid:
		ambient_mgr.player.fade_pause(VOL_OFF_DB, fade_time)

func resume(fade_time:float = 0): music_mgr.resume(music_volume_db, fade_time)
func resume_ambient(fade_time:float = 0): ambient_mgr.resume(ambient_volume_db, fade_time)
