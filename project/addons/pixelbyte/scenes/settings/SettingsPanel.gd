extends Dialog

var settings:SettingsData setget ,get_settings
func get_settings() -> SettingsData: return settings

var music_bus_index :int
var sfx_bus_index :int
var ambient_bus_index :int

func write_settings(): settings.save()
func read_settings(): 
	settings.read()
	update_from_settings()
	
func button_pressed(btn:Button):
	.button_pressed(btn)
	if result == "Cancel" or result == "No":
		read_settings()
	else:
		write_settings()

func _init():
	settings = SettingsData.new()
	
func _ready():
	music_bus_index = AudioServer.get_bus_index("Music")
	sfx_bus_index = AudioServer.get_bus_index("Sfx")
	ambient_bus_index = AudioServer.get_bus_index("Ambient")
	update_from_settings()
	_connect_signals()

func _closed_with_escape():
	result = "Cancel"
	read_settings()
	
func update_from_settings():
	set_slider_settings($MC/Controls/MasterGroup/MasterSlider, limit_audio_vol(settings.masterVol))
	_on_MasterSlider_value_changed(settings.masterVol)
	
	# disable any channels that don't exist in the AudioBus
	# Assume 'Master' always exists!
	if music_bus_index == -1:
		$MC/Controls/MusicGroup.visible = false
	else:
		set_slider_settings($MC/Controls/MusicGroup/MusicSlider, limit_audio_vol(settings.musicVol))
		_on_MusicSlider_value_changed(settings.musicVol)
		
	if sfx_bus_index == -1:
		$MC/Controls/SfxGroup.visible = false
	else:
		set_slider_settings($MC/Controls/SfxGroup/SfxSlider, limit_audio_vol(settings.sfxVol))
		_on_SfxSlider_value_changed(settings.sfxVol)
		
	if ambient_bus_index == -1:
		$MC/Controls/AmbientGroup.visible = false
	else:
		set_slider_settings($MC/Controls/AmbientGroup/AmbientSlider, limit_audio_vol(settings.ambientVol))
		_on_AmbientSlider_value_changed(settings.ambientVol)
			
	$MC/Controls/FullscreenCheck.pressed = settings.fullscreen
	OS.window_fullscreen = settings.fullscreen

func limit_audio_vol(value:float) -> float: return clamp(value, 0, 100)
func convert_percent_to_db(value:int) -> float:
	return range_lerp(value, 0, 100, SettingsData.MIN_DB_VOL, SettingsData.MAX_DB_VOL)

func set_slider_settings(slider:Slider, value:float = 0):
	if slider == null:
		printerr("Specified slider does not exist!")
	else:
		slider.min_value = 0
		slider.max_value = 100
		slider.step = 1
		slider.value = value

func _connect_signals():
	var slider = $MC/Controls/MasterGroup/MasterSlider
	if !slider.is_connected("value_changed", self, "_on_MasterSlider_value_changed"):
		slider.connect("value_changed", self, "_on_MasterSlider_value_changed")
	
	slider = $MC/Controls/SfxGroup/SfxSlider
	if !slider.is_connected("value_changed", self, "_on_SfxSlider_value_changed"):
		slider.connect("value_changed", self, "_on_SfxSlider_value_changed")

	slider = $MC/Controls/AmbientGroup/AmbientSlider
	if !slider.is_connected("value_changed", self, "_on_AmbientSlider_value_changed"):
		slider.connect("value_changed", self, "_on_AmbientSlider_value_changed")

	slider = $MC/Controls/MusicGroup/MusicSlider
	if !slider.is_connected("value_changed", self, "_on_MusicSlider_value_changed"):
		slider.connect("value_changed", self, "_on_MusicSlider_value_changed")
	
	var checkbox = $MC/Controls/FullscreenCheck
	if !checkbox.is_connected("toggled", self, "_on_FullscreenCheck_toggled"):
		checkbox.connect("toggled", self, "_on_FullscreenCheck_toggled")
	
func _on_MasterSlider_value_changed(value):
	settings.masterVol = value
	set_bus("Master", $MC/Controls/MasterGroup/Value, value)

func _on_MusicSlider_value_changed(value):
	settings.musicVol = value
	set_bus("Music", $MC/Controls/MusicGroup/Value, value)

func _on_SfxSlider_value_changed(value):
	settings.sfxVol = value
	set_bus("Sfx", $MC/Controls/SfxGroup/Value, value)

func _on_AmbientSlider_value_changed(value):
	settings.ambientVol = value
	set_bus("Ambient", $MC/Controls/AmbientGroup/Value, value)
	
func set_bus(name:String, label:Label, value:int):
	label.text = "%s%%" % value
	var db = convert_percent_to_db(value)
	settings.set_vol(name, db)

func _on_FullscreenCheck_toggled(checked):
	settings.fullscreen = checked
	OS.window_fullscreen = checked
	
