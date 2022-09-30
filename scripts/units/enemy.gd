extends Unit
class_name Enemy
## VERY placeholder right now

onready var player_detection: PlayerDetection = $PlayerDetection
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
	return player_detection.get_player_if_detected()


## is this redundant?
func is_player_detected() -> bool:
	return player_detection.is_player_detected()
