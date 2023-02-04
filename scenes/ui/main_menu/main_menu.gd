 extends CanvasLayer
class_name MainMenu
## it's the main menu


signal button_pressed()


export var first_level_code := "1a"

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

	# set up each button to signal with its own name (its level code)
	for lb in level_select_container.get_node("LevelButtonsContainer").get_children():
		lb.connect(
			"pressed",
			self,
			"on_level_select_button_pressed",
			[lb.name]
		)
		level_buttons[lb.name] = lb


func start_new_game():
	emit_signal("button_pressed")
	on_level_select_button_pressed(first_level_code)


func quit_game():
	emit_signal("button_pressed")
	get_tree().quit()


func go_to_main_menu():
	emit_signal("button_pressed")
	main_menu_container.visible = true
	level_select_container.visible = false


## adjusts the level select menu based on current save data
func go_to_level_select():
	emit_signal("button_pressed")
	var data := SaveLoad.load_data()
	var level_list := []
	if 'level_list' in data:
		level_list = data['level_list']

	var set_atleast_one := false
	# buttons default to not visible
	for level_code in level_list:
		level_buttons[level_code].visible = true
		set_atleast_one = true

	if set_atleast_one:
		no_levels_label.visible = false
	main_menu_container.visible = false
	level_select_container.visible = true


func on_level_select_button_pressed(level_code: String):
	if is_working:
		return
	else:
		emit_signal("button_pressed")
		is_working = true
		timer.start()
		yield(timer, "timeout")
		LevelLoader.load_level(
			level_scene_paths[level_code],
			true# skip player data
		)

