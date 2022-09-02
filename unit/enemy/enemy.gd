extends Unit
class_name Enemy
## VERY placeholder right now

onready var player_detection = $PlayerDetection


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
			return n
	return null


## is this redundant?
func has_detected_player() -> bool:
	return get_player_if_detected() != null
