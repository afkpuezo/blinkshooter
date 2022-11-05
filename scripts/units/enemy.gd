extends Unit
class_name Enemy
## VERY placeholder right now


## msg args: "player"
signal detected_player(msg)

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

# NOTE: has to be onready or our position will not be set yet!
onready var last_known_player_position: Vector2 = self.position

# blegh name, keeping track of this explicitly avoids an infinite loop with
# messaging
var can_currently_see_player := false


# -
# ----------
# from Node / basic util methods
# ----------
# -


func _ready() -> void:
	GameEvents.emit_signal("enemy_spawned", {'enemy': self})


func _physics_process(delta: float) -> void:
	#if name == "Enemy":
	#	print("DEBUG: %s can currently see player: %s" % [name, can_currently_see_player])
	think(delta)


# -
# ----------
# inherited from Unit
# ----------
# -


## if shot by the player from far away, we know where they are
func take_damage(amount: int, source):
	#print("DEBUG: enemy take_damage() amount / source: %d / %s" % [amount, source.name])
	if source.has_method("_is_player_help"):
		last_known_player_position = source.global_position
	.take_damage(amount, source)


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
	var target_position

	var check_results = player_detection.check()
	var is_player_detected: bool = check_results["is_player_detected"]
	var player = check_results["player"]
	var is_detected_by_center = check_results["is_detected_by_center"]

	if is_player_detected:
		can_currently_see_player = true
		target_position = player.position
		last_known_player_position = player.position
	else:
		can_currently_see_player = false
		target_position = last_known_player_position

	var moved = false

	var distance_squared = position.distance_squared_to(target_position)
	self.look_at(target_position)

	if is_player_detected:
		if is_detected_by_center:
			attack()
		# only back away from the player, not an empty space where they used to
		# be
		if distance_squared < too_close_squared:
			enemy_mover.back_away_from(self, movement_stats, delta, target_position)
			moved = true

	# don't move to or stand still if we've already backed away from the player
	if not moved:
		if distance_squared > chasing_squared:
			enemy_mover.move_to(self, movement_stats, delta, target_position)
		else:
			enemy_mover.stand_still(self, movement_stats, delta)


## random equipped action
func attack():
	# warning-ignore:return_value_discarded
	weapon_bar.trigger_random_action()


## A little redundant with the signal, but this method allows for other logic here if needed
func report_detected_player(player):
	emit_signal("detected_player", {'player': player})


## receive a message from another enemy about the player's location
func receive_enemy_message(msg):
	pass
