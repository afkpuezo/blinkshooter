extends Unit
class_name Enemy
## VERY placeholder right now

onready var player_detection: PlayerDetection = $PlayerDetection
# seperate from radius of PlayerDetection, effectively the real threshold is the minimum of the two
export var maximum_detection_range := 256
onready var range_squared = pow(maximum_detection_range, 2)
onready var weapon_bar: EnemyWeaponBar = $EnemyWeaponBar



func _physics_process(delta: float) -> void:
	._physics_process(delta) # movement in super
	think()


# -
# ----------
# new in Enemy
# ----------
# -


# ----------
# behavior related
# ----------


## holds behavior logic
##		currently only attacks, movement is handled by the mover
## should be called in _physics_process() (or _process()?)
func think():
	if should_attack():
		attack()


## returns true if this enemy should attack the player right now
## currently only cares if the player is detected or not
func should_attack() -> bool:
	return player_detection.is_player_detected()


## random equipped action
func attack():
	weapon_bar.trigger_random_action()


# ----------
# player-detection related
# ----------


## Returns null if the player is not currently in the detection area
func get_player_if_detected() -> Player:
	return player_detection.get_player_if_detected()


## is this redundant?
func is_player_detected() -> bool:
	return player_detection.is_player_detected()
