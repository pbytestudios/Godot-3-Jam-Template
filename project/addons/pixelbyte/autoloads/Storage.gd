extends Node2D
#
# 2022 Pixelbyte Studios
# This is a save/load script for gamedata
# Either setup a subDir in the editor, set it up in script, or ignore it
# This also has resource save/load functionality as well
# to use it, add it as an autoload

const SAVE_ROOT := "user://"

export var subDir := "" setget set_subDir, get_subDir

func set_subDir(value: String): subDir = value
func get_subDir() -> String: return subDir
func fullPath(filename:String):
	if !subDir.empty():
		return "%s%s//%s" % [SAVE_ROOT, subDir, filename]
	else:		
		return "%s%s" % [SAVE_ROOT, filename]

#
# given a filename, this returns true if the file exists
# false otherwise
#
func exists(filename:String) -> bool:
	var f = File.new()
	var exists = f.file_exists(fullPath(filename))
	f.close()
	return exists

func delete(filename:String) -> bool:
	var dir = Directory.new()
	return dir.remove(fullPath(filename)) == OK

#
# Given a filename, some content, and an optional encryption key
# this method saves the given data to a file
#
func write(content, filename:String,passkey:String):
	_write(content, filename, true, passkey)
func write_bin(content, filename:String,passkey:String):
	_write(content, filename, false, passkey)
	
func _write(content, filename:String, write_string:bool, passkey:String):
	var file = File.new()
	if passkey.empty():
		file.open(fullPath(filename), File.WRITE)
	else:
		file.open_encrypted_with_pass(fullPath(filename), File.WRITE, passkey)
	
	if write_string:
		file.store_string(var2str(content))
	else:
		file.store_var(content)
	file.close()

#
# Given a filename, and an optional encryption key
# this method load data from the given file
#
func read(filename:String, passkey:String = "") -> Dictionary:
	return _read(filename, true, passkey)
	
func read_bin(filename:String, passkey:String = "") -> Dictionary:
	return _read(filename, false, passkey)
	
func _read(filename:String, read_string:bool, passkey:String) -> Dictionary:
	var file = File.new()
	# if the file does not exist, return an empty dictionary
	var loadedData = {}
	if exists(filename):
		if passkey.empty():
			file.open(fullPath(filename), File.READ)
		else:
			file.open_encrypted_with_pass(fullPath(filename), File.READ, passkey)
		
		if read_string:
			var txt = file.get_as_text()
			loadedData = str2var(txt)
		else:
			loadedData = file.get_var()
		file.close()
	return loadedData

#
# JSON save/load functions
#
func read_json(filename: String, passkey:String="", supress_file_not_found:bool = false) -> Dictionary:
	var data: String = ""
	var file: File = File.new()
	var err: int
	if passkey.empty():
		err = file.open(fullPath(filename), File.READ)
	else:
		err = file.open_encrypted_with_pass(fullPath(filename), File.READ, passkey)
	if err == OK:
		data = file.get_as_text()
		file.close()
	else:
		if !supress_file_not_found:
			printerr("Error opening file '%s'!" % filename)
		return {}
	
	var result: JSONParseResult = JSON.parse(data)
	if result.error != OK: 
		printerr("JSON parse error for '%s' [%d]!\n%s" % [filename, result.error, result.error_string])
		#I'm choosing to just return a blank dictionary here
		return {}
	else:
		return result.result

func write_json(data: Dictionary, filename: String, passkey:String="") -> int:
	var file: File = File.new()
	var err: int
	if passkey.empty():
		err = file.open(fullPath(filename), File.WRITE)
	else:
		err = file.open_encrypted_with_pass(fullPath(filename), File.WRITE, passkey)
	if err == OK:
		file.store_string(JSON.print(data))
		file.close()
	return err

#
# These methods allow save/load of cfg files
# cfg files can save all the Godot types unlike JSON
#
func write_cfg(cfg:ConfigFile, filename: String, passkey:String = "") -> int:
	var err:int
	if passkey.empty():
		err = cfg.save(fullPath(filename))
	else:
		err = cfg.save_encrypted_pass(fullPath(filename), passkey)
	if err == ERR_FILE_CANT_WRITE :
		printerr("Failed to write settings file '%'" % fullPath(filename))
	elif err != OK:
		printerr("Error writing file '%s' %d" % [fullPath(filename), err])
	return err

func open_cfg(filename: String, passkey:String = "") -> ConfigFile:
	var cfg = ConfigFile.new()
	var err:int
	if passkey.empty():
		err = cfg.load(fullPath(filename))
	else:
		err = cfg.load_encrypted_pass(fullPath(filename), passkey)
	if err == ERR_FILE_NOT_FOUND:
		print("Settings file '%s' not found." % fullPath(filename))
	elif err != OK:
		printerr("Unable to load settings file '%s'" % fullPath(filename))
	return cfg
#
# The two functions below are used to save/load resources
# which can be handy to use as savegame data
#
# NOTE: File extension must be one of the following 
# for text (.tres) or binary file (.res).
#
func write_resource(filename: String, content:Resource):
	ResourceSaver.save(fullPath(filename), content)

func resource_exists(res_filename:String) -> bool:
	var filePath = fullPath(res_filename)
	return ResourceLoader.exists(filePath)
		
func read_resource(filename:String, delete_if_error :bool = false, supress_not_found:bool = false, type_hint:String = "") -> Resource:
	var filePath = fullPath(filename)
	#from https://www.youtube.com/watch?v=TGdQ57qCCF0
	#if not ResourceLoader.has_cached(filePath):
	#load the resource and replace any cached version with the new one
	#if this behaves unexpectedly, check your version of godot with
	#the status of https://github.com/godotengine/godot/issues/59686
	#to see if the bug has been fixed yet
	if not ResourceLoader.exists(filePath):
		if !supress_not_found:
			printerr("File path: %s does not exist. Returning null..." % filePath)
		return null
			
	var res := ResourceLoader.load(filePath,type_hint, true)
	#this should delete the resource if it has an error loading
	if res == null and delete_if_error:
		delete(filename)
	return res
