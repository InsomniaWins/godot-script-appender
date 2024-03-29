extends Control

var _directory_path:String
var _project_folder_name:String
var total_code = ""

func _ready():
	
	_directory_path = OS.get_cmdline_args()[0]
	var last_folder_begin_char = _directory_path.find_last("/") + 1
	var last_folder_name_length = _directory_path.length() - last_folder_begin_char
	_project_folder_name = _directory_path.substr(last_folder_begin_char, last_folder_name_length)
	
	var scripts = get_all_scripts(_directory_path)
	
	for script_name in scripts:
		var file_contents:String = get_file_contents(script_name)
		total_code = total_code + "\n\n\n -- " + script_name + " --\n"
		total_code = total_code + file_contents
	
	var save_path:String = _directory_path + "/total_code.txt"
	print("saved total_code.txt to ", save_path)
	save_text_to_file(save_path, total_code)
	get_tree().quit()

func save_text_to_file(file_name:String, text:String):
	
	var file = File.new()
	file.open(file_name, File.WRITE)
	file.store_string(text)
	file.close()
	

func get_file_contents(file_name:String):
	var file:File = File.new()
	var file_contents:String = ""
	var file_open_status = file.open(file_name, File.READ)
	
	if file_open_status != OK:
		print("Failed to open ", file_name, ": ", file_open_status)
	
	file_contents = file.get_as_text()
	
	file.close()
	
	return file_contents

func get_all_scripts(directory_path:String) -> Array:
	var scripts = []
	var directory:Directory = Directory.new()
	directory.open(directory_path)
	
	directory.list_dir_begin(true)
	
	while true:
		var file = directory.get_next()
		
		if file.empty():
			break
		
		if directory.current_is_dir():
			if directory_path.ends_with(_project_folder_name):
				if file == "addons" or file == ".vscode" or file == ".import":
					continue
			scripts.append_array(get_all_scripts(directory_path + "/" + file))
		
		if file.begins_with("."):
			continue
		
		if !file.ends_with(".gd"):
			continue
		
		scripts.append(directory_path + "/" + file)
	
	directory.list_dir_end()
	
	return scripts
