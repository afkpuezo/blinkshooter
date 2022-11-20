extends Unit
class_name Enemy
## VERY placeholder right now


## msg args: "player"
signal detected_player(msg)


# -- child nodes
onready var player_detection: PlayerDetection = $PlayerDetection
## when the enemy sees the player, this timer starts. As long as the timer is
onready var player_memory_timer: Timer = $PlayerMemoryTimer

onready var enemy_mover: EnemyMover = $EnemyMover # mover var declared in parent class - bad?
onready var weapon_bar: EnemyWeaponBar = $EnemyWeaponBar


## -- behavior control
# seperate from radius of PlayerDetection, effectively the real threshold is the minimum of the two
export var minimum_chase_distance := 200
export var too_close_threshold := 100
export var minimum_chase_distance_no_player := 10

# NOTE: has to be onready or our position will not be set yet!
onready var last_known_player_position: Vector2 = self.position

## blegh name, keeping track of this explicitly avoids an infinite loop with
## messaging
## this is only set to true while the player is in vision, and is false when
## the enemy is trying to get to where the player was last seen
var can_currently_see_player := false


## an instance of this weapon is added to the weapon bar
export(PackedScene) var starting_weapon_scene = load("res://scenes/weapons/enemy_gun.tscn")


# -
# ----------
# from Node / basic util methods
# ----------
# -


func _ready() -> void:
	GameEvents.emit_signal("enemy_spawned", {'enemy': self})

	if starting_weapon_scene:
		weapon_bar.add_action(starting_weapon_scene.instance())


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
	var true_source = Player.get_player_if_source(source)
	if true_source:
		#last_known_player_position = source.global_position
		_update_knowledge_of_player(true, true_source)
	.take_damage(amount, true_source)


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

	var check_results = player_detection.check()
	var is_player_detected: bool = check_results["is_player_detected"]
	var player = check_results["player"]
	var is_detected_by_center = check_results["is_detected_by_center"]

	if is_player_detected:
		_update_knowledge_of_player(true, player)
	else:
		_update_knowledge_of_player(false)

	var moved = false

	#var distance_squared = position.distance_squared_to(last_known_player_position)
	var distance = position.distance_to(last_known_player_position)
	self.look_at(last_known_player_position)

	if is_player_detected:
		if is_detected_by_center:
			attack()
		# only back away from the player, not an empty space where they used to
		# be
		#if distance_squared < too_close_squared:
		if distance < too_close_threshold:
			enemy_mover.back_away_from(self, movement_stats, delta, last_known_player_position)
			moved = true

	# don't move to or stand still if we've already backed away from the player
	if not moved:
		var too_close = false
		if is_player_detected and distance < minimum_chase_distance:
			too_close = true
		elif (not is_player_detected) and distance < minimum_chase_distance_no_player:
			too_close = true

		if too_close:
			enemy_mover.stand_still(self, movement_stats, delta)
		else:
			enemy_mover.move_to(self, movement_stats, delta, last_known_player_position)


## random equipped action
func attack():
	# warning-ignore:return_value_discarded
	weapon_bar.trigger_random_action()


# ----------
# communication related
# ----------


## Call this instead of updating the var value directly
## If going from false to true, reports the new detection of the player
## If setting to true, updates the last known location to the player's location
## I didn't use a setget since it can require the player var
## Player should be included if setting to true, not included if setting to false
## Has a timer that doesn't allow can_currently_see_player to be set to false
## 	when it has recently been updated to true; the player can be between two of
## 	the rays and the enemy will think it's lost them for a moment
func _update_knowledge_of_player(new_value: bool, player = null):
	if new_value:
		player_memory_timer.start()
		last_known_player_position = player.global_position
		if not can_currently_see_player:
			# setting it here so that it's true before sending a message, to avoid
			# a possible infinite loop of messaging back and forth forever
			can_currently_see_player = true
			_report_detected_player(player)
	else: # if new_value is false
		if player_memory_timer.is_stopped():
			can_currently_see_player = new_value


## A little redundant with the signal, but this method allows for other logic here if needed
func _report_detected_player(player):
	#print("DEBUG: Enemy._report_detected_player() called")
	emit_signal("detected_player", {'player': player})


## receive a message from another enemy about the player's location
## expects msg to include: 'player'
func receive_enemy_message(msg):
	_update_knowledge_of_player(true, msg['player'])
