class_name Bar
extends PanelContainer

signal onscreen
signal offscreen

var tween :SceneTreeTween
var tweening_off:bool

func _ready():
	hide()

func on(text:String, time:float= 0.25) -> Bar:
	modulate.a = 0
	$Label.text = text
	show()
	if tween && tween.is_running():
		tween.stop()
	
	tween = create_tween()
	tween.set_pause_mode(SceneTreeTween.TWEEN_PAUSE_PROCESS)	
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 1.0, time)
	tween.connect("finished", self, "emit_onscreen",[], CONNECT_ONESHOT)
	return self

func emit_onscreen(): 
	tween = null
	emit_signal("onscreen")

func emit_offscreen():
	tween = null
	hide()
	emit_signal("offscreen")

func off(time:float = 0.5) -> Bar:
	modulate.a = 1.0
	tweening_off = true
	if tween && tween.is_running():
		tween.stop()
		
	tween = create_tween()
	tween.set_pause_mode(SceneTreeTween.TWEEN_PAUSE_PROCESS)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 0.0, time)
	tween.connect("finished", self, "emit_offscreen",[], CONNECT_ONESHOT)
	return self
