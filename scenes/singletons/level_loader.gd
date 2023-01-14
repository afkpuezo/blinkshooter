extends Node
#class_name LevelLoader


var demo_scene_name = "res://scenes/demos/demo.tscn"
var level_one_scene_name = "res://scenes/levels/level_one.tscn"


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("load_demo"):
		get_tree().change_scene(demo_scene_name)
	elif Input.is_action_just_pressed("load_level_1"):
		get_tree().change_scene(level_one_scene_name)
