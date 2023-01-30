extends Node
# singleton
## Responsible for saving and loading the save game file (which stores the list
## of unlocked levels)


const FILE_PATH = "save_data.dat"


## this method is likely only for debugging
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("save_data"):
		save_data()
	elif Input.is_action_just_pressed("load_data"):
		load_data()


func save_data():
	print("save_data() called")
	var file := File.new()
	file.open(FILE_PATH, File.WRITE)

	var level_list := ["level_1a", "level_1b", "level_1c"]
	var data := {
		'level_list': level_list,
	}
	var data_string := to_json(data)

	file.store_line(data_string)
	file.close()


func load_data():
	print("load_data() called")
	var file := File.new()
	if file.file_exists(FILE_PATH):
		file.open(FILE_PATH, File.READ)

		var raw := file.get_line()
		var content = parse_json(raw)

		file.close()
		print("load_data content: %s" % content)
		print("load_data is a dictionary?: %s" % content is Dictionary)
	else:
		print("no save file found!")
