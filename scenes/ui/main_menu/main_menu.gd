extends CanvasLayer
class_name MainMenu
## it's the main menu


export var first_level_scene_path := "res://scenes/levels/level_1/level_1a.tscn"

onready var timer: Timer = $Timer
var is_working := false


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
