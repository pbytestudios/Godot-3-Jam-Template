class_name ObservableFloat
extends Observable

export(float) var val : float setget set_val, get_val
func set_val(newVal:float):
	var oldVal :float = _val
	
	_val = newVal
	if !Engine.editor_hint:
		_onChanged()
		if lowerThreshold < INF && oldVal > lowerThreshold && _val <= lowerThreshold:
			emit_signal("below_threshold", lowerThreshold, _val)
		if upperThreshold > -INF && oldVal < upperThreshold && _val >= upperThreshold:
			emit_signal("aboveThreshold", upperThreshold, _val)

func get_val() -> float: return _val

#if value goes below this, then the below_threshold signal is sent
export(float) var lowerThreshold :float = INF
#if value goes above this, then the above_threshold signal is sent
export(float) var upperThreshold :float = -INF
#if set then the current value of this number will be sent 1 frame after _ready() is called
signal below_threshold(lower_threshold, value)
signal aboveThreshold(upper_threshold, value)

func _init() -> void: _val = 0.0
