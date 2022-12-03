extends Node2D
class_name EnemyIdler
## component of EnemyBrain, used while the Enemy is idling.
## angles the Enemy as if they were looking around


export var max_turn_deg := 20.0 # left or right
onready var max_turn := deg2rad(max_turn_deg)
export var turn_rate_deg := 20.0 # per second
onready var turn_rate := deg2rad(turn_rate_deg)

var is_turning_left: bool
var current_base_angle: float
var current_min_angle: float
var current_max_angle: float

# used to control reset of starting angle
onready var memory_timer: Timer = $MemoryTimer


## rotate the enemy back and forth
## assumes called during physics process
func idle(enemy: Unit):
	if should_reset():
		current_base_angle = enemy.rotation
		current_min_angle = current_base_angle - max_turn
		current_max_angle = current_base_angle + max_turn
		is_turning_left = false

	var delta = get_physics_process_delta_time()

	if is_turning_left:
		enemy.rotate(-1 * turn_rate * delta)
		if enemy.rotation <= current_min_angle:
			is_turning_left = false
	else: # turning right
		enemy.rotate(turn_rate * delta)
		if enemy.rotation >= current_max_angle:
			is_turning_left = true


## updates the memory timer.
## if the timer was stopped before updating, return true, else false
func should_reset() -> bool:
	var was_stopped = memory_timer.is_stopped()
	memory_timer.start()
	return was_stopped
