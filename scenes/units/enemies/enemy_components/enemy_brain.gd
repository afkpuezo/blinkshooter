extends Node2D
class_name EnemyBrain
## This used to be the Enemy script. Now it's just a component of a unit that
## turns that unit into an enemy.


## msg args: "player"
signal detected_player(msg)

# chasing covers currently seeing the player and having recently seen them
enum MODE{IDLE, CHASING}


# ----------
# vars
# ----------

# easier to make changes later than using owner everywhere
onready var this_unit: Unit = owner

# -- child nodes
onready var player_detection: PlayerDetection = $PlayerDetection
## when the enemy sees the player, this timer starts. As long as the timer is
onready var player_memory_timer: Timer = $PlayerMemoryTimer

onready var enemy_mover: EnemyMover = $EnemyMover # mover var declared in parent class - bad?
onready var movement_stats: MovementStats = MovementStats.get_movement_stats(this_unit)
onready var weapon_bar: EnemyWeaponBar = $EnemyWeaponBar
onready var enemy_idler: EnemyIdler = $EnemyIdler

## -- behavior control
# seperate from radius of PlayerDetection, effectively the real threshold is the minimum of the two
export var minimum_chase_distance := 200
export var too_close_threshold := 100
export var minimum_chase_distance_no_player := 10

# NOTE: has to be onready or our position will not be set yet!
onready var last_known_player_position: Vector2 = this_unit.position

## blegh name, keeping track of this explicitly avoids an infinite loop with
## messaging
## this is only set to true while the player is in vision, and is false when
## the enemy is trying to get to where the player was last seen
var can_currently_see_player := false
var did_player_teleport := false
var current_mode: int = MODE.IDLE

# -
# ----------
# from Node / basic util methods
# ----------
# -


func _ready() -> void:
	GameEvents.emit_signal("enemy_spawned", {'enemy': this_unit})
	GameEvents.connect("player_teleported", self, "on_player_teleported")


func _physics_process(delta: float) -> void:
	think()


# -
# ----------
# inherited from Unit
# ----------
# -


## if shot by the player from far away, we know where they are
func on_unit_took_damage(amount: int, source):
	var true_source = PlayerBrain.get_player_if_source(source)
	if true_source:
		_update_knowledge_of_player(true, true_source)


func die():
	var msg = {
		'global_position': global_position
	}
	GameEvents.emit_signal("enemy_died", msg)
	.die()


# -
# ----------
# new in Enemy
# ----------
# -


# ----------
# behavior related
# ----------


## holds behavior logic
## should be called in _physics_process() (or _process()?)
func think():

	var check_results = player_detection.check()
	var is_player_detected: bool = false if did_player_teleport else check_results["is_player_detected"]
	var player: Unit = check_results["player"]
	var is_detected_by_center: bool = check_results["is_detected_by_center"]

	if is_player_detected:
		# could update mode
		_update_knowledge_of_player(true, player)
	else:
		_update_knowledge_of_player(false, null, did_player_teleport)

	# should handle every case
	match current_mode:
		MODE.CHASING:
			_think_chase(
				is_player_detected,
				player,
				is_detected_by_center
			)
		MODE.IDLE:
			_think_idle()

	did_player_teleport = false
# end think()


## if player is detected:
##		- look at player
##		- try to attack
##		- if far away, move closer
##		- if too close, back away
##		- if just right, stand still
## if player is not detected:
##		- move to their last known position
func _think_chase(
	is_player_detected: bool,
	player: Unit,
	is_detected_by_center: bool
	):
	var delta = get_process_delta_time()
	var moved = false

	var distance = position.distance_to(last_known_player_position)
	this_unit.look_at(last_known_player_position)

	if is_player_detected:
		if is_detected_by_center:
			attack()
		# only back away from the player, not an empty space where they used to
		# be
		#if distance_squared < too_close_squared:
		if distance < too_close_threshold:
			enemy_mover.back_away_from(this_unit, movement_stats, delta, last_known_player_position)
			moved = true

	# don't move to or stand still if we've already backed away from the player
	if not moved:
		var too_close = false
		if is_player_detected and distance < minimum_chase_distance:
			too_close = true
		elif (not is_player_detected) and distance < minimum_chase_distance_no_player:
			too_close = true

		if too_close:
			enemy_mover.stand_still(this_unit, movement_stats, delta)
		else:
			enemy_mover.move_to(this_unit, movement_stats, delta, last_known_player_position)
# end _think_chase()


func _think_idle():
	enemy_idler.idle(this_unit)


## random equipped action
func attack():
	# warning-ignore:return_value_discarded
	weapon_bar.trigger_random_action()


## triggered by the GameEvent, forces the enemy to lose sight of the player
func on_player_teleported():
	#_update_knowledge_of_player(false, null, true)
	did_player_teleport = true


## Call this instead of updating the var value directly
## If going from false to true, reports the new detection of the player
## If setting to true, updates the last known location to the player's location
## I didn't use a setget since it can require the player var
## Player should be included if setting to true, not included if setting to false
## Has a timer that doesn't allow can_currently_see_player to be set to false
## 	when it has recently been updated to true; the player can be between two of
## 	the rays and the enemy will think it's lost them for a moment
## ignore_timer only matters when setting to false
## will update current mode to CHASING if going from false -> true
func _update_knowledge_of_player(
	incoming_value: bool,
	player = null,
	ignore_timer = false
	):
	if incoming_value == true:
		current_mode = MODE.CHASING
		player_memory_timer.start()
		last_known_player_position = player.global_position
		if not can_currently_see_player:
			# setting it here so that it's true before sending a message, to avoid
			# a possible infinite loop of messaging back and forth forever
			can_currently_see_player = true
			_report_detected_player(player)
	else: # if incoming_value is false
		if ignore_timer or player_memory_timer.is_stopped():
			can_currently_see_player = false


func on_EnemyMover_reached_target() -> void:
	if not can_currently_see_player:
		current_mode = MODE.IDLE


# ----------
# communication related
# ----------


## A little redundant with the signal, but this method allows for other logic here if needed
func _report_detected_player(player):
	emit_signal("detected_player", {'player': player})


## receive a message from another enemy about the player's location
## expects msg to include: 'player'
func receive_enemy_message(msg):
	_update_knowledge_of_player(true, msg['player'])

