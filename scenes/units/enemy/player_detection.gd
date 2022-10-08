extends Node2D
class_name PlayerDetection


onready var user = owner
onready var ray: RayCast2D = $RayCast2D
onready var area: Area2D = $Area2D
export var maximum_detection_range := 256
onready var range_squared = pow(maximum_detection_range, 2)


## Returns null if the player is not currently detected
func get_player_if_detected() -> Player:
	# first check if the player is close enough
	var bodies = area.get_overlapping_bodies()
	if bodies.empty():
		return null

	var player: Player
	for body in bodies:
		if body is Player:
			player = body
			break

	# now try raycast
	ray.look_at(player.position)
	if ray.is_colliding():
		#print("DEBUG: PlayerDetection.get_player_if_detected(): ray is colliding")
		# have to declare and type result of get_collider()?
		var hit = ray.get_collider()
		if hit is Player:
			return hit
	return null


## is this redundant?
func is_player_detected() -> bool:
	return get_player_if_detected() != null

