class_name Observable
extends Node

var _val

signal changed(newVal)

#if set then the current value of this number will be sent 1 frame after _ready() is called
export(bool) var signalAfterReady :bool = false

func _onChanged():
	emit_signal("changed", _val)

func _ready() -> void:
	if signalAfterReady:
		call_deferred("_onChanged")
