extends Node2D

export(Texture) var transition_texture:Texture

onready var dlg:Dialog = $CanvasLayer/Dialog
onready var settings:Dialog = $CanvasLayer/SettingsPanel

var disable:bool 

func _ready():
	disable = true
	ScreenTransition.transition(true)
	yield(ScreenTransition, "transitioned_fully")
	disable = false

func _unhandled_input(event):
	if disable:
		return
	#todo: put stuff here
	pass
