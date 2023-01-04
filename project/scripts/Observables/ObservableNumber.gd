class_name ObservableNumber
extends Node

#this should be either a float or an int
var _val = 0

signal changed(newVal)

#if set then the current value of this number will be sent 1 frame after _ready() is called
export(bool) var signalAfterReady :bool = false

func _onChanged():
	emit_signal("changed", _val)

func _ready() -> void:
	if signalAfterReady:
		call_deferred("_onChanged")
