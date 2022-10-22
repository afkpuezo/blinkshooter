extends Unit
class_name Enemy
## VERY placeholder right now

## -- child nodes
onready var player_detection: PlayerDetection = $PlayerDetection
onready var enemy_mover: EnemyMover = $EnemyMover # mover var declared in parent class - bad?
onready var weapon_bar: EnemyWeaponBar = $EnemyWeaponBar


## -- behavior control
# seperate from radius of PlayerDetection, effectively the real threshold is the minimum of the two
export var minimum_chase_distance := 200
export var too_close_threshold := 100

onready var chasing_squared = pow(minimum_chase_distance, 2) # faster calculations apparently
onready var too_close_squared = pow(too_close_threshold, 2)
onready var stop_looking_distance = pow(player_detection.detection_range, 2)


func _physics_process(delta: float) -> void:
	think(delta)


# -
# ----------
# new in Enemy
# ----------
# -


# ----------
# behavior related
# ----------


## holds behavior logic
## if player is detected:
##		- look at player
##		- try to attack
##		- if far away, move closer
##		- if too close, back away
##		- if just right, stand still
## if player is not detected:
##		- stand still
## should be called in _physics_process() (or _process()?)
func think(delta):
	var player = player_detection.get_player_if_detected()

	if player:
		var distance_squared = position.distance_squared_to(player.position)

		self.look_at(player.position)

		if should_attack():
			attack()

		if distance_squared > chasing_squared:
			enemy_mover.move_to(self, movement_stats, delta, player.position)
		elif distance_squared < too_close_squared:
			enemy_mover.back_away_from(self, movement_stats, delta, player.position)
		else:
			enemy_mover.stand_still(self, movement_stats, delta)

	else: # no player
		enemy_mover.stand_still(self, movement_stats, delta)


## returns true if this enemy should attack the player right now
## currently only cares if the player is detected or not
func should_attack() -> bool:
	return player_detection.is_player_detected()


## random equipped action
func attack():
# warning-ignore:return_value_discarded
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

