extends Node2D
#class_name CameraManager
## singleton for getting the player attached/detached from the player character
## when appropriate


var player_camera_scene = load("res://scenes/ui/player_camera.tscn")

var player_camera: Camera2D = player_camera_scene.instance()


func _ready() -> void:
	GameEvents.connect("player_spawned", self, "on_player_spawn")
	GameEvents.connect("player_died", self, "on_player_died")


## have the camera follow the player when they spawn
func on_player_spawn(msg):
	var player = msg['player']
	player.add_child(player_camera)
	# setting it here rather than in the scene sets any other cameras to false
	player_camera.current = true


## have the camera stay still when the player dies
func on_player_died(msg):
	var player = msg['player']
	player.remove_child(player_camera)
	player_camera.global_position = player.global_position
	add_child(player_camera)
