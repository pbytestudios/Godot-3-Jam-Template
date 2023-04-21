class_name FadeStream
extends AudioStreamPlayer

#author: Pixelbyte Studios LLC

var tween:SceneTreeTween

func fade_play(final_vol_db:float, fade_time:float):
	stream_paused = false
	if fade_time <= 0:
		kill_tween()
		volume_db = final_vol_db
		play()
	else:
		_make_tween().set_ease(Tween.EASE_OUT)
		play()
		tween.tween_property(self, "volume_db", final_vol_db, fade_time)
	
func fade_stop(vol_off_db:float, fade_time:float):
	if fade_time <= 0:
		kill_tween()
		stop()
		volume_db = vol_off_db		
	else:
		_make_tween().set_ease(Tween.EASE_IN)
		tween.tween_property(self, "volume_db", vol_off_db, fade_time)
		#adds a callback to stop() the stream after the volume is tweened
		tween.tween_callback(self, "stop")

func fade_pause(vol_off_db:float, fade_time:float):
	if fade_time <= 0:
		kill_tween()
		stream.paused = true
		volume_db = vol_off_db
	else:
		_make_tween().set_ease(Tween.EASE_IN)
		tween.tween_property(self, "volume_db", vol_off_db, fade_time)
		#adds a callback to stop() the stream after the volume is tweened
		tween.tween_callback(self, "set_stream_paused", [true])	

func kill_tween():
	if tween && is_instance_valid(tween):
		tween.kill()
		tween = null

func _make_tween() -> SceneTreeTween:
	kill_tween()
	#this creates a SceneTreeTween and binds it to this object so it is freed when this object is
	tween = create_tween().set_trans(Tween.TRANS_QUAD)
	return tween
	
func fade_to(vol_final_db:float, fade_time:float) -> SceneTreeTween:
	_make_tween()
	tween.tween_property(self, "volume_db", vol_final_db, fade_time)
	return tween
