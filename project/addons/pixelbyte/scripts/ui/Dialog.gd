class_name Dialog
extends PanelContainer

export(bool) var escape_closes:bool = false
export(bool) var hide_on_ready:bool = true

#https://victorkarp.com/godot-engine-creating-references-to-nodes/
export (NodePath) onready var title_label = get_node(title_label) as Label if title_label else null

export (NodePath) var message_path:NodePath
export (NodePath) var button_container_path:NodePath
export (NodePath) var veil_path:NodePath
export (Vector2) var button_size:Vector2 = Vector2(100,50)

#Option Button sound connections
export(NodePath) var hover_sound_path:NodePath
export(NodePath) var pressed_sound_path:NodePath

var button_holder :Container
var focus_index: int = -1

var speed_scale:float = 1.0 setget set_speed_scale
func set_speed_scale(val:float): speed_scale = val

var result:String setget ,get_result
func get_result(): return result

var title:String = "" setget set_title,get_title
func set_title(val:String): if title_label: title_label.text = val
func get_title() -> String:
	if !is_instance_valid(title_label): return ""
	return title_label.text

var msg:String = ""  setget set_msg,get_msg
func get_msg() -> String: return get_node(message_path).text if message_path else ""
func set_msg(val:String): if message_path: get_node(message_path).text = val

var hover_sound:AudioStreamPlayer
var pressed_sound:AudioStreamPlayer

func _ready():
	button_holder = get_node(button_container_path)
	if hide_on_ready:
		hide()

	if hover_sound_path:
		hover_sound = get_node(hover_sound_path)
	if pressed_sound_path:
		pressed_sound = get_node(pressed_sound_path)
	
	hook_up_existing_buttons()
		
func hook_up_existing_buttons():
	#Existing buttons? hook 'em up'
	for btn in button_holder.get_children():
		if !btn.is_connected("pressed", self, "button_pressed"):
			btn.connect("pressed", self, "button_pressed", [btn])
		btn.rect_min_size = button_size
		if hover_sound:
			btn.connect("mouse_entered", self, "_mouse_entered", [btn])
	focus_index = 0

func set_button_min_size():
	for btn in button_holder.get_children():
		btn.rect_min_size = button_size
	
func _focus_button(index:int):
	if index < 0 || index >= button_holder.get_child_count():
		return
	var button:Button = button_holder.get_child(index)
	button.grab_focus()

func _add_button(text:String) -> Button:
	var btn = Button.new()
	btn.text = text
	btn.rect_min_size = button_size
	button_holder.add_child(btn)
	btn.connect("pressed", self, "button_pressed", [btn])
	if hover_sound:
		btn.connect("mouse_entered", self, "_mouse_entered", [btn])
		
	return btn

func button_pressed(btn:Button):
	result = btn.text
	if pressed_sound:
		pressed_sound.play()	
	hide()
	
func remove_all_buttons():
	for child in button_holder.get_children():
		child.queue_free()
	focus_index = -1

func remove_buttons_from_end(to_remove:int):
	if to_remove <= 0: 
		return
	var num_current = button_holder.get_child_count()
	
	for i in range(num_current - 1, num_current - 1 - to_remove,  -1):
		button_holder.get_child(i).queue_free()

func make_buttons(num_needed:int):
	var num_current = button_holder.get_child_count()
	var to_add = num_needed - num_current
	
#	print("add: %d" % to_add)
	if to_add > 0:
		for _i in range(to_add):
			_add_button("")
	elif to_add < 0:
		remove_buttons_from_end(-to_add)

func show():
	if veil_path:
		get_node(veil_path).visible = true
	
	set_button_min_size()
	
	result = ""
	if button_holder.get_child_count() == 0:
		_add_button("Ok")
		focus_index = 0
		
	if has_node("Anim"):
		get_node("Anim").playback_speed = speed_scale
		get_node("Anim").play("Pop")
	.show()
	_focus_button(focus_index)
	return self

func inform(message:String, _title:String) -> Dialog:
	set_title(_title)
	set_msg(message)
	set_buttons(["Ok"], 0)
	return show()

func confirm(question:String, _title:String = "Confirm", yes:String ="Yes", no:String="No", focusYes:bool = false) -> Dialog:
	set_title(_title)
	set_msg(question)
	set_buttons([yes, no], 0 if focusYes else 1)
	return show()

func ask(question:String, _title:String, buttons:Array =["Yes", "No"], default_btn_index:int = 0) -> Dialog:
	set_title(_title)
	set_msg(question)
	set_buttons(buttons, min(default_btn_index, buttons.size() - 1))
	return show()
	
func _unhandled_input(event):
	if event is InputEventKey and event.is_pressed() and escape_closes and visible:
		var ek : InputEventKey = event as InputEventKey
		if ek.scancode == KEY_ESCAPE:
			_closed_with_escape()
			call_deferred("hide")
			
#override this to do something 'special' when 'escape_closes = true' and the escape key is pressed
func _closed_with_escape(): pass

func hide():
	if veil_path:
		get_node(veil_path).visible = false
		
	if !visible:
		result = ""
		return
		
	if has_node("Anim"):
		get_node("Anim").playback_speed = speed_scale
		get_node("Anim").play_backwards("Pop")
		yield(get_node("Anim"),"animation_finished")
	.hide()

func set_buttons(button_names:Array, focus:int = -1):
	if button_names == null or button_names.size() == 0:
		remove_all_buttons()
		return
	#make/delete any needed buttons
	make_buttons(button_names.size())

	#update the button labels
	for i in range(0, button_names.size()):
		button_holder.get_child(i).text = button_names[i]
	focus_index = focus

func _mouse_entered(btn:Button):
	#don't emit the hover sound if the button already has focus
	if btn == get_focus_owner():
		return
	hover_sound.play()
