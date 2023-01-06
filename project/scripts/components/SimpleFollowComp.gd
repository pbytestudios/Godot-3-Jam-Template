class_name SimpleFollowComp
extends Node2D

export(NodePath) onready var velocityComp = get_node(velocityComp) if VelocityComp else null
export(float) var min_follow_dist := 10.0
export(bool) var instant_stop := false

var target:Node2D setget set_target, get_target
func get_target() -> Node2D: return target
func set_target(val:Node2D): 
	target = val
	if target:
		state = SetVelocity

enum {Init, SetVelocity, Following, Waiting}
var state := Init

func _process(delta: float) -> void:
	match state:
		SetVelocity:
			if !is_instance_valid(target):
				state = Init
			else:
				var dir = (target.global_position - global_position).normalized()
				velocityComp.accelerate_to(dir)
				state = Following
		Following:
			if !is_instance_valid(target):
				velocityComp.decelerate(0.0, instant_stop)
				state = Init
			else:
				var dist_away := global_position.distance_to(target.global_position)
				if dist_away <= min_follow_dist:
					velocityComp.decelerate(0.0, instant_stop)
					state = Waiting
				else:
					state = SetVelocity
		Waiting:
			var dist_away := global_position.distance_to(target.global_position)
			if dist_away > min_follow_dist:
				state = SetVelocity
