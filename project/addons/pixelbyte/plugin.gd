tool
extends EditorPlugin

const NODE_PCAM_2D = "PixelCam2D"
const NODE_SOUNDER = "Sounder"
const NODE_SOUNDER_2D = "Sounder2D"
const NODE_FADE_PLAYER = "FadeStream"

#Autoload singleton names
const AUTOLOAD_TRANSITION = "Transition"
const AUTOLOAD_MUSIC = "Music"
const AUTOLOAD_STORAGE = "Storage"

#settings for this addon
const SETTING_ENABLE_TRANSITION = "addons/pixelbyte/enable_screen_transition"
const SETTING_ENABLE_MUSIC = "addons/pixelbyte/enable_music"
const SETTING_ENABLE_STORAGE = "addons/pixelbyte/enable_storage"

#scenes/scripts for this addon
var music_scene = preload("autoloads/music/Music.tscn")
var storage_script = preload("autoloads/Storage.gd")

func _enter_tree():
	#add custom types here
	add_custom_type(NODE_SOUNDER, "AudioStreamPlayer", preload("node_lib/Sounder.gd"), null)
	add_custom_type(NODE_SOUNDER_2D, "AudioStreamPlayer2D", preload("node_lib/Sounder2D.gd"), null)

	ProjectSettings.connect("project_settings_changed", self, "on_project_settings_changed")
	
	#add my addon settings here
	set_setting_initial(SETTING_ENABLE_TRANSITION, false)
	set_setting_initial(SETTING_ENABLE_MUSIC, false)
	set_setting_initial(SETTING_ENABLE_STORAGE, false)
	
func _exit_tree():
	remove_custom_type(NODE_PCAM_2D)
	remove_custom_type(NODE_SOUNDER)
	remove_custom_type(NODE_SOUNDER_2D)
	remove_custom_type(NODE_FADE_PLAYER)
	
	remove_autoload_singleton(AUTOLOAD_TRANSITION)
	remove_autoload_singleton(AUTOLOAD_MUSIC)
	remove_autoload_singleton(AUTOLOAD_STORAGE)

func erase_setting(setting_path:String):
	if ProjectSettings.has_setting(setting_path):
		ProjectSettings.set_setting(setting_path, null)
		
func set_setting_initial(setting_path:String, default_val:bool = false):
	if not ProjectSettings.has_setting(setting_path):
		ProjectSettings.set_setting(setting_path, false)
	ProjectSettings.set_initial_value(setting_path, false)
	
func get_setting_or_false(setting_path:String) -> bool:
	if not ProjectSettings.has_setting(setting_path): 
		set_setting_initial(setting_path, false)
		return false
	return ProjectSettings.get_setting(setting_path)	
	
func update_autoload_singleton(setting:String, singleton_name:String, resPath:String):
	if ProjectSettings.has_setting(setting) and ProjectSettings.get_setting(setting) == true:
		add_autoload_singleton(singleton_name, resPath)
	else:
		remove_autoload_singleton(setting)

func on_project_settings_changed():
	update_autoload_singleton(SETTING_ENABLE_MUSIC, AUTOLOAD_MUSIC, music_scene.resource_path)
	update_autoload_singleton(SETTING_ENABLE_STORAGE, AUTOLOAD_STORAGE, storage_script.resource_path)
