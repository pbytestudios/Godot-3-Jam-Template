tool
extends Polygon2D

var collision_poly: CollisionPolygon2D

func _ready():
	#we do not need this script in-game
	if !Engine.editor_hint:
		 set_script(null)
	else:
		call_deferred("get_collision_poly")

func _process(delta):
	if Engine.editor_hint:
		if !collision_poly:
			get_collision_poly()

		var adjusted : PoolVector2Array = []
		for p in self.polygon:
			adjusted.push_back(p)
		collision_poly.polygon = adjusted
		collision_poly.global_position = global_position
	
func get_collision_poly():
	#Looks for a sibling CollisionPolygon2D
	var parent = get_parent()
	for node in parent.get_children():
		if node is CollisionPolygon2D:
			collision_poly = node
			return
	
	#if the collision polygon was not found, create and add it
	collision_poly = CollisionPolygon2D.new()
	parent.add_child(collision_poly)
	#lock the new node so it cannot be selected
	collision_poly.set_meta("_edit_lock_", true)
	
	# This is needed to make the node visible in the Scene tree dock
	# and persist changes made by the tool script to the saved scene file.
	collision_poly.set_owner(get_tree().edited_scene_root)
