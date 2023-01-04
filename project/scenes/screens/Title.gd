extends Node2D

export(Resource) onready var game_version = game_version as VersionData
export(Texture) var transition_texture:Texture

onready var dlg:Dialog = $CanvasLayer/Dialog
onready var settings:Dialog = $CanvasLayer/SettingsPanel

func _ready() -> void:
	ScreenTransition.set_transition_texture(transition_texture)
	ScreenTransition.set_transition_color(C.TRANSITION_COLOR)
	disable = true
	ScreenTransition.transition(true)
	yield(ScreenTransition, "transitioned_fully")
	disable = false
			
	$CanvasLayer/Title/Title.text = ProjectSettings.get("application/config/name")
	$CanvasLayer/Title/Desc.text = ProjectSettings.get("application/config/description")
	$CanvasLayer/Title/Version.text = "Version: %s" % game_version.version
	
	settings.connect("hide", self, "_on_settings_dlg_hidden")

	if C.is_platform_html5():
		$CanvasLayer/PanelContainer/MarginContainer/Menu/Exit.visible = false
	
	$CanvasLayer/PanelContainer/MarginContainer/Menu/Play.grab_focus()
	
	#todo: play music here?

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel") && settings.visible:
		settings.hide()
		
func _on_Play_pressed() -> void:
	if disable:return
	disable = true
	ScreenTransition.transition_to_scene("res://scenes/screens/Game.tscn")
	
func _on_Settings_pressed() -> void:
	if disable:
		return
	$CanvasLayer/SettingsPanel.show()

func _on_settings_dlg_hidden():
	$CanvasLayer/PanelContainer/MarginContainer/Menu/Play.grab_focus()

var disable:bool
func _on_Exit_pressed() -> void:
	if disable:return
	disable = true
	
	dlg.title = "Confirm"
	dlg.msg = "Exit?"
	dlg.set_buttons(["Yes","No"], 1)
	dlg.show()
	yield(dlg,"hide")
	match dlg.result:
		"Yes":
			ScreenTransition.transition()
			yield(ScreenTransition,"transitioned_halfway")
			get_tree().quit()
		_:
			disable = false
			$CanvasLayer/PanelContainer/MarginContainer/Menu/Exit.grab_focus()
