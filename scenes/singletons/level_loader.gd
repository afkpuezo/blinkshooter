extends Node
#class_name LevelLoader


# TODO find a better way to set initial level
var current_level_name = "res://scenes/levels/level_one_a.tscn"
var player: Unit
var player_data: Dictionary
var is_waiting_for_player_spawn := false

const PLAYER_DEATH_LOAD_DELAY := 2.0


func _ready() -> void:
	# warning-ignore:return_value_discarded
	GameEvents.connect("player_died", self, "on_player_death")
	# warning-ignore:return_value_discarded
	GameEvents.connect("player_spawned", self, "on_player_spawn")


## i guess this is the best place to handle quitting
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()


func on_player_spawn(msg):
	player = msg['player']
	if is_waiting_for_player_spawn:
		load_player_data()
		is_waiting_for_player_spawn = false


func save_player_data():
	player_data = PlayerBrain.save_player_state(player)


func load_player_data():
	PlayerBrain.load_player_state(player, player_data)


func load_level(level_name: String, is_from_player_death: bool = false):
	# if the player died, don't store their new resource values
	if not is_from_player_death:
		save_player_data()

	current_level_name = level_name
	is_waiting_for_player_spawn = true
	# warning-ignore:return_value_discarded
	get_tree().change_scene(current_level_name)


func on_player_death(_args = null):
	yield(get_tree().create_timer(PLAYER_DEATH_LOAD_DELAY, false), "timeout")
	load_level(current_level_name, true)
