class_name SettingsData
extends Reference

const MIN_DB_VOL = -45 #actually, it is -80db for full off
const MAX_DB_VOL = 0 #actually, it goes up to 24 but we don't allow that

const SETTINGS_FILE := "settings.dat"
const SETTINGS_SECTION := "Settings"

#These are the default values that we store in the settings file
const S_MASTER := "masterVol"
const S_SFX := "sfxVol"
const S_MUSIC := "musicVol"
const S_AMBIENT := "ambientVol"
const S_FULLSCREEN := "fullscreen"

#this holds any settings that are added via the add() function
var other_settings: Array = []

var cfg:ConfigFile

func _init():
	read()

func _set(key:String, val) -> bool:
	cfg.set_value(SETTINGS_SECTION, key, val)
	return true

func _get(key:String):
	match key:
		S_MASTER, S_SFX, S_MUSIC, S_AMBIENT: return cfg.get_value(SETTINGS_SECTION, key, 100)
		S_FULLSCREEN: return cfg.get_value(SETTINGS_SECTION, key, false)
		#Add any more settings default values here
		_: 
			if other_settings.has(key): return cfg.get_value(SETTINGS_SECTION, key)
			printerr("'%s' is not a valid setting!" % key)
			return 0

func add(key:String, def_val, section:String = SETTINGS_SECTION):
	if cfg.has_section_key(section, key): return
	cfg.set_value(section, key, def_val)
	
func read(filename:String = SETTINGS_FILE):
	if !Storage.exists(filename):
		cfg = ConfigFile.new()
		Storage.write_cfg(cfg, filename)
	else:
		cfg = Storage.open_cfg(filename)
	
func save(filename:String = SETTINGS_FILE):
	Storage.write_cfg(cfg, filename)

static func set_vol(bus_name:String, value_db:int):
	var index = AudioServer.get_bus_index(bus_name)
	if index > -1:
		AudioServer.set_bus_volume_db(index, value_db)
		AudioServer.set_bus_mute(index, value_db == MIN_DB_VOL)		
