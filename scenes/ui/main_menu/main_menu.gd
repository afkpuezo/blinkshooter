 extends CanvasLayer
class_name MainMenu
## it's the main menu


export var first_level_scene_path := "res://scenes/levels/level_1/level_1a.tscn"

onready var timer: Timer = $Timer
var is_working := false

onready var main_menu_container: Container = $MainMenuContainer
onready var level_select_container: Container = $LevelSelectContainer
onready var no_levels_label: Label = $LevelSelectContainer/NoLevelsLabel


func _ready() -> void:
	PauseManager.is_pausable = false
	$AnimationPlayer.play("Intro")
	PlayerUI.visible = false


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


