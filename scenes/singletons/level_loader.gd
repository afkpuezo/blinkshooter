extends Node
#class_name LevelLoader


# TODO find a better way to set initial level
var current_level_name = "res://scenes/levels/level_one_a.tscn"

const PLAYER_DEATH_LOAD_DELAY := 2.0


func _ready() -> void:
	# warning-ignore:return_value_discarded
	GameEvents.connect("player_died", self, "on_player_death")


func load_level(level_name):
	current_level_name = level_name
	get_tree().change_scene(level_name)


func on_player_death(_args):
	yield(get_tree().create_timer(PLAYER_DEATH_LOAD_DELAY, false), "timeout")
	load_level(current_level_name)
