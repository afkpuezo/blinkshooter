extends Node
# singleton LevelLoader


var player: Unit
var player_data: Dictionary
var is_waiting_for_player_spawn := true

const PLAYER_DEATH_LOAD_DELAY := 4.0


func _ready() -> void:
	# warning-ignore:return_value_discarded
	GameEvents.connect("player_died", self, "on_player_death")
	# warning-ignore:return_value_discarded
	GameEvents.connect("player_spawned", self, "on_player_spawn")


func on_player_spawn(msg):
	player = msg['player']
	if is_waiting_for_player_spawn:
		if player_data:
			load_player_data()
		is_waiting_for_player_spawn = false


func save_player_data():
	if player:
		player_data = PlayerBrain.save_player_state(player)


func load_player_data():
	PlayerBrain.load_player_state(player, player_data)


func load_level(level_scene_path: String, skip_data: bool = false):
	# if the player died, don't store their new resource values
	if not skip_data:
		save_player_data()
		# putting this here means you heal to full after death
		is_waiting_for_player_spawn = true

	# warning-ignore:return_value_discarded
	GameEvents.emit_signal("level_loaded", {'level_scene_path': level_scene_path})
	get_tree().change_scene(level_scene_path)


func on_player_death(_args = null):
	yield(get_tree().create_timer(PLAYER_DEATH_LOAD_DELAY, false), "timeout")
	load_level(LevelGlobal.level_scene_path, true)
