extends Node

const TRANSITION_COLOR = Color.black

var platform :String setget ,get_platform
func get_platform() -> String: 
	if platform.empty():
		platform = OS.get_name()
	return platform
func is_platform_html5() -> bool: return platform == "HTML5"

