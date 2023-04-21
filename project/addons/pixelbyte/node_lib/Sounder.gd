class_name Sounder
extends AudioStreamPlayer

const MIN_PITCH := 0.1 
const MIN_INCREMENT := 0.05

# This is a property
export(Array, AudioStream) var sounds
#if != 0 this adds a random +/- offset to the pitch each time it plays
export(float, -1, 0, 0.1) var random_pitch_min = 0.0
export(float, 0, 1, 0.1) var random_pitch_max = 0.0

onready var original_pitch: float = pitch_scale
var rnd := RandomNumberGenerator.new()

func _ready() -> void:
	rnd.randomize()

func set_random_sound():
	if sounds.size() > 1:
		stream = sounds[rnd.randi_range(0, sounds.size() - 1)]
	else:
		stream = sounds[0]

func play(from_pos := 0.0):
	if sounds.size() == 0: 
		return
	
	set_random_sound()
	
	#we want the increments to be in discrete increments
	var u = random_pitch_min / MIN_INCREMENT
	var m = random_pitch_max / MIN_INCREMENT
	var offset = rnd.randi_range(u, m)
	
	if offset != 0:
		pitch_scale = max(MIN_PITCH, original_pitch + offset * MIN_INCREMENT)
	else:
		pitch_scale = original_pitch
	.play(from_pos)
