class_name StringReceiver
extends Label

export(String) var format :String = "%.d"
export(NodePath) onready var sender = get_node_or_null(sender) as ObservableInt if sender else null 

func _ready() -> void:
	if is_instance_valid(sender):
		sender.connect("changed", self, "on_sender_changed")
	if sender == null:
		printerr("[%s] sender was null!" % name)

func on_sender_changed(newVal:float):
	if format.empty():
		text = str(newVal)
	else:
		text = format % newVal
