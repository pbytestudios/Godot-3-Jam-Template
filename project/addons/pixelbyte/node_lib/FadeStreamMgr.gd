class_name FadeStreamMgr
extends Resource

const VOL_OFF_DB = -80

#author: Pixelbyte Studios LLC

export (String, DIR) var music_folder = "music"
export (bool) var fade_to_pause = false

#Add as many AudioStreamPlayers as we want to switch between here
var _audio_stream_players:Array = []
var _stream_names: Dictionary = {}

#currently_playing stream index
var _index:int = -1

#emitted when the stream content finishes playing
#will not emit if the stream is stopped, paused or has been imported with loop = true
#parameters: name of the file that the stream is connected to
signal stream_finished(filename)

#returns true if the current player is valid
var player_valid:bool setget ,get_player_valid
func get_player_valid() -> bool: return _index > -1

#returns the current FadeStream
var player:FadeStream setget ,get_current_player
func get_current_player() -> FadeStream:
	if _index > -1:	return _audio_stream_players[_index]
	else: return null

#returns the filename for the current FadeStream
var filename:String setget ,get_filename
func get_filename() -> String: 
	if self.player_valid && _stream_names.has(self.player):
		return _stream_names[self.player]
	else:
		return ""

func add_players(players:Array):
	for player in players:	
		if !_audio_stream_players.has(player):
			_audio_stream_players.append(player)
			if !player.is_connected("finished", self, "_on_stream_done"):
				player.connect("finished", self, "_on_stream_done")
		
func next_player() -> FadeStream:
	_index = wrapi(_index+1,0, _audio_stream_players.size())
	return _audio_stream_players[_index]
	
func _fade(stream_player:AudioStreamPlayer, fade_time:float, final_vol_db:float):
	if !stream_player:
		printerr("stream_player was null!")
		return
	stream_player.fade_play(final_vol_db, fade_time)

func resume(final_vol_db:float, fade_time: float = 0) -> bool:
	var player = self.player
	if !player || !self.player_valid || !player.playing:
		return false
	
	player.volume_db = VOL_OFF_DB
	player.stream_paused = false
	player.fade_to(final_vol_db, fade_time).set_ease(Tween.EASE_OUT)
	return true
	
func play(filename:String, final_vol_db:float, fade_time: float = 0):
	var prev = self.player
	
	#is there a stream in our array that already has this filename loaded?
	if _set_as_stream_if_exists(filename):
		var pl = self.player
		pl.volume_db = VOL_OFF_DB
		if !pl.playing:
			pl.fade_play(final_vol_db, fade_time)
			return
		else:
			pl.stream_paused = false
			pl.fade_to(final_vol_db, fade_time).set_ease(Tween.EASE_OUT)
	else:
		var filepath:String = _fullpath(filename)
		var audio_stream = load(filepath)
		if audio_stream:
			var pl = next_player()
			pl.stream = audio_stream
			pl.volume_db = VOL_OFF_DB
			_stream_names[pl] = filename
			pl.fade_play(final_vol_db, fade_time)
		else:
			printerr("Unable to find audio file: %s" % filepath)
		
	if prev && prev != self.player && prev.playing:
		if fade_to_pause:
			prev.fade_pause(VOL_OFF_DB, fade_time)
		else:
			prev.fade_stop(VOL_OFF_DB, fade_time)

func _set_as_stream_if_exists(filename:String) -> bool:
	var player:FadeStream
	for plyr in _stream_names.keys():
		if _stream_names[plyr] == filename:
			player = plyr
			break
	if !player:
		return false
			
	for i in range(0, _audio_stream_players.size()):
		if _audio_stream_players[i] == player:
			_index = i
			return true
	return false
	
func _fullpath(filename:String) -> String:
	if music_folder.empty():
		return filename
	if not music_folder.ends_with("/"):
		music_folder += "/"
	return 	music_folder + filename

func _on_stream_done():
	emit_signal("stream_finished", get_filename())
