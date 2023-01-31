extends Node
# singleton
## Responsible for saving and loading the save game file (which stores the list
## of unlocked levels)


const FILE_PATH = "save_data.dat"

# NOTE: some overlap with main menu, maybe centralize
var level_codes := {
	'res://scenes/levels/level_1/level_1a.tscn': '1a',
	'res://scenes/levels/level_1/level_1b.tscn': '1b',
	'res://scenes/levels/level_1/level_1c.tscn': '1c',
	'res://scenes/levels/level_2/level_2a.tscn': '2a',
	'res://scenes/levels/level_2/level_2b.tscn': '2b',
	'res://scenes/levels/level_2/level_2c.tscn': '2c',
	'res://scenes/levels/level_2/level_2d.tscn': '2d',
}


func _ready() -> void:
	GameEvents.connect("level_loaded", self, "on_level_loaded")


## this method is likely only for debugging
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("load_data"):
		load_data()


func on_level_loaded(msg):
	var level_scene_path: String = msg['level_scene_path']
	var level_name = level_codes[level_scene_path]
	var data := load_data()

	if not 'level_list' in data:
		data['level_list'] = []

	if not level_name in data['level_list']:
		data['level_list'].append(level_name)
		save_data(data)


func save_data(data: Dictionary):
	#print("DEBUG: save_data(), data is %s" % data)
	var file := File.new()
	file.open(FILE_PATH, File.WRITE)

	var data_string := to_json(data)
	file.store_line(data_string)
	file.close()


## could be modified to cache data rather than load each time?
func load_data() -> Dictionary:
	var data := {}

	var file := File.new()
	if file.file_exists(FILE_PATH):
		file.open(FILE_PATH, File.READ)

		var raw := file.get_line()
		data = parse_json(raw)
		file.close()

	#print("DEBUG: load_data(), data is %s" % data)
	return data
