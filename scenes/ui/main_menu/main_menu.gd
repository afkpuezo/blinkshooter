 extends CanvasLayer
class_name MainMenu
## it's the main menu


export var first_level_scene_path := "res://scenes/levels/level_1/level_1a.tscn"

onready var timer: Timer = $Timer
var is_working := false

onready var main_menu_container: Container = $MainMenuContainer
onready var level_select_container: Container = $LevelSelectContainer
onready var no_levels_label: Label = $LevelSelectContainer/NoLevelsLabel
# level_code: String -> button
var level_buttons := {}
# level_code: String -> scene_path: String
# NOTE: no 2e cuz its just the victory screen basically
export var level_scene_paths := {
	'1a': 'res://scenes/levels/level_1/level_1a.tscn',
	'1b': 'res://scenes/levels/level_1/level_1b.tscn',
	'1c': 'res://scenes/levels/level_1/level_1c.tscn',
	'2a': 'res://scenes/levels/level_2/level_2a.tscn',
	'2b': 'res://scenes/levels/level_2/level_2b.tscn',
	'2c': 'res://scenes/levels/level_2/level_2c.tscn',
	'2d': 'res://scenes/levels/level_2/level_2d.tscn',
}


func _ready() -> void:
	PauseManager.is_pausable = false
	$AnimationPlayer.play("Intro")
	PlayerUI.visible = false
	# level_code: String -> sub dict with ['button'], ['level_scene_path']
	for lb in level_select_container.get_node("LevelButtonsContainer").get_children():
		pass


func start_new_game():
	if is_working:
		return
	else:
		is_working = true
		timer.start()
		yield(timer, "timeout")
		LevelLoader.load_level(first_level_scene_path, true) # skip player data


func quit_game():
	get_tree().quit()


func go_to_main_menu():
	main_menu_container.visible = true
	level_select_container.visible = false


## adjusts the level select menu based on current save data
func go_to_level_select():
	main_menu_container.visible = false
	level_select_container.visible = true


func on_level_select_button(level_code: String):
	print("DEBUG: on_level_select_button(): level_code: %s" % level_code)

