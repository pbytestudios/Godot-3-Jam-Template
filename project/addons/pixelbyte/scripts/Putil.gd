#
# Pixelbyte utilities and such
#
class_name Putil
extends Node2D

#
# Given a node, a type, and an empty array, this function
# returns ALL the sub-nodes of the given type
# Note: This function can be called multiple times on the same
# array as it will not erase anything already in it
#
static func get_children_of_type_rec(n:Node, type, array:Array):
	if n.get_child_count() > 0:
		for child in n.get_children():
			get_children_of_type_rec(child, type, array)
	elif n is type:
		array.push_back(n)

#non-recursive version of the above function
static func get_children_of_type(n:Node, type) -> Array:
	var arr:Array = []
	for child in n.get_children():
		if child is type:
			arr.push_back(child)
	return arr
		
static func get_children_with_class(n:Node, className:String) -> Array:
	var array := []
	for child in n.get_children():
		if child.get_class() == className:
			array.push_back(child)
	return array
	
# Looks for the first node of type 'type' within the scene
# tree and returns either it or null
# NOTE: In order for this to work, you must override get_class() in the script
# for which you want this to work:
# func get_class(): return "YourClassName"
#otherwise it will return the base class of the node itself
static func get_first_child_of_class(n:Node, className:String):
	if className.empty():
		return
	for child in n.get_children():
		if child.get_class() == className:
			return child
	return null
#
# Takes a screenshot of the display and saves it to the 
# given filename in the 'user://' directory
#
static func screenshot(node:Node2D, filename:String):
	node.get_viewport().set_clear_mode(Viewport.CLEAR_MODE_ONLY_NEXT_FRAME)
	# Wait until the frame has finished before getting the texture.
	yield(VisualServer, "frame_post_draw")

	# Retrieve the captured image.
	var img := node.get_viewport().get_texture().get_data()

	# Flip it on the y-axis (because it's flipped).
	img.flip_y()
	img.save_png("user://%s" % filename)
