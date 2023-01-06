tool
extends CanvasLayer

signal transitioned_halfway
signal transitioned_fully

onready var animation_player = $AnimationPlayer

var is_transitioning:bool setget ,get_transitioning
func get_transitioning() -> bool:
	return animation_player.is_playing()

func _enter_tree():
	add_to_group(name)


func transition_to_scene(scene_path: String):
	transition()
	yield(self, "transitioned_halfway")
	get_tree().change_scene(scene_path)


func transition(play_half:bool = false):
	if animation_player.is_playing():
		animation_player.stop(true)
	$Sfx.play()	
	animation_player.play("transition")
	if play_half:
		animation_player.seek(animation_player.current_animation_length / 2.0 + 0.01, true)

func set_transition_texture(texture: Texture):
	get_node("TransitionRect").material.set_shader_param("transition_texture", texture)


func set_transition_color(color: Color):
	get_node("TransitionRect").material.set_shader_param("transition_color", color)


func set_speed_scale(scale: float):
	animation_player.playback_speed = scale


func emit_transitioned_halfway():
	emit_signal("transitioned_halfway")
	$Sfx.play()

func emit_transitioned_fully():
	emit_signal("transitioned_fully")
