class_name VelocityComp
extends Observable

#max speed allowed
export(float) var max_speed :float = 100

# acceleration per second
export(float, 0.01, 1.0) var acceleration_coeff : float = 0.75

var velocity : Vector2 = Vector2.ZERO setget set_velocity, get_velocity
func get_velocity() -> Vector2: return _val
func set_velocity(val:Vector2):
	_val = val
	_onChanged()

var speed_percent :float setget ,get_speed_percent
func get_speed_percent() -> float: return _val.length() / max_speed

func accelerate_to(new_dir:Vector2, new_speed:float = max_speed):
	desired_dir = new_dir.normalized()
	desired_speed = min(new_speed, max_speed)
	set_process(true)

func set_instant_vel(new_dir:Vector2, new_speed:float = max_speed):
	set_process(false)
	self.velocity = new_dir * min(new_speed, max_speed)
	desired_dir = new_dir.normalized()
	desired_speed = min(new_speed, max_speed)

func decelerate(to_speed:float = 0.0, instant:bool = false):
	if instant:
		self.velocity = self.velocity.normalized() * min(to_speed, max_speed)
	desired_dir = self.velocity.normalized()
	desired_speed = min(to_speed, max_speed)
	set_process(true)

func move(body:KinematicBody2D):
	body.move_and_slide(self.velocity)

#vf = vi + at
var desired_dir:Vector2
var desired_speed:float
func _process(delta: float) -> void:
	self.velocity = self.velocity.linear_interpolate(desired_dir * desired_speed, 1 - pow(1 - acceleration_coeff, delta))
	if self.velocity.is_equal_approx(desired_dir * desired_speed):
		self.velocity = desired_dir * desired_speed
		set_process(false)

func _init() -> void:
	_val = Vector2.ZERO
	set_process(false)
