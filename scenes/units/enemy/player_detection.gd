extends Node2D
class_name PlayerDetection


onready var user = owner
onready var area = $Area2D
export var maximum_detection_range := 256
onready var range_squared = pow(maximum_detection_range, 2)


## Returns null if the player is not currently in the detection area
func get_player_if_detected() -> Player:
	var overlaps = area.get_overlapping_bodies() # should be areas?
	for n in overlaps:
#		print("DEBUG: EnemyMover.physics_update() found node in overlapping bodies: %s" % n.name)
		if Player.is_player(n):
			#print("DEBUG: player found, distance squared: %d" % position.distance_squared_to(n.position))
			return n if owner.position.distance_squared_to(n.position) <= range_squared else null
	return null


## is this redundant?
func is_player_detected() -> bool:
	return get_player_if_detected() != null

