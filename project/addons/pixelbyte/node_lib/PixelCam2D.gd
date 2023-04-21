class_name PixelCam2D
extends Camera2D

#Camera shake parameters
enum ShakeType {Random, Sine, Noise}

export (int) var noise_octaves := 4
export (int) var noise_period := 20
export (float) var noise_persistence := 0.8

var is_shaking :bool = false setget ,get_is_shaking
func get_is_shaking(): return _duration > 0

var _intensity :Vector2 = Vector2.ZERO
var _type = ShakeType.Random
var _noise : OpenSimplexNoise
var _duration :float = 0.0
#######

func _ready():
	_noise = OpenSimplexNoise.new()
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	_noise.seed = rng.randi()
	
	# These parameters change the shape of the noise
	# and the feel of the shake
	_noise.octaves = noise_octaves
	_noise.period = noise_period
	_noise.persistence = noise_persistence
	set_process(false)	

func shake(shake_duration: float, shake_intensity : Vector2 = Vector2.ONE, type:int = ShakeType.Random):
	if shake_duration > _duration:
		_intensity = shake_intensity
		_duration = shake_duration
		_type = type
		set_process(true)
		
func stop(): 
	set_process(false)
	yield(get_tree(),"idle_frame")
	_duration = 0
	_intensity = Vector2.ZERO
	offset = Vector2.ZERO
	
func _process(delta):
	if _duration > 0:
		_duration -= delta
		
		match _type:
			ShakeType.Random:
				offset = Vector2(randf(), randf()) * _intensity
			ShakeType.Sine:
				offset = Vector2(sin(OS.get_ticks_msec() * 0.03) * _intensity.x, sin(OS.get_ticks_msec() * 0.07) * _intensity.y) * 0.5
			ShakeType.Noise:
				var _noise_value_x = _noise.get_noise_1d(OS.get_ticks_msec() * 0.1)
				var _noise_value_y = _noise.get_noise_1d(OS.get_ticks_msec() * 0.1 + 100.0)
				offset = Vector2(_noise_value_x, _noise_value_y) * _intensity * 2.0
				
		if _duration <= 0:
			stop()

func set_limits(limits:Rect2):
	limit_left = int(limits.position.x)
	limit_top = int(limits.position.y)
	limit_right = int(limits.end.x)
	limit_bottom = int(limits.end.y)

func zoom_to_limits(limits:Rect2):
	var zoom = limits.size / get_viewport_rect().size
	#take the larger number to keep the aspect ratio correct while fitting everything within the camear
	set_zoom( Vector2.ONE * max(stepify(zoom.x, 0.1), stepify(zoom.y, 0.1)))
	global_position = limits.get_center()
