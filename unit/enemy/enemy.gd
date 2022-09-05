extends Unit
class_name Enemy
## VERY placeholder right now

onready var player_detection = $PlayerDetection
# seperate from radius of PlayerDetection, effectively the real threshold is the minimum of the two
export var maximum_detection_range := 256
onready var range_squared = pow(maximum_detection_range, 2)


# -
# ----------
# new in Enemy
# ----------
# -


# ----------
# player-detection related
# ----------


## Returns null if the player is not currently in the detection area
func get_player_if_detected() -> Player:
	var overlaps = player_detection.get_overlapping_bodies() # should be areas?
	for n in overlaps:
#		print("DEBUG: EnemyMover.physics_update() found node in overlapping bodies: %s" % n.name)
		if n is Player:
			#print("DEBUG: player found, distance squared: %d" % position.distance_squared_to(n.position))
			return n if position.distance_squared_to(n.position) <= range_squared else null
	return null


## is this redundant?
func is_player_detected() -> bool:
	return get_player_if_detected() != null
