extends Node2D
class_name EnemyIdler
## component of EnemyBrain, used while the Enemy is idling.
## angles the Enemy as if they were looking around


var patrol_path = null # set in ready
# getting cleverTM to use this timer in two different ways
onready var timer: Timer = $Timer

# -
# used WITH a patrol path
var is_waiting_for_next_point := false
export var next_point_wait_time := 1.0
export var patrol_point_distance_threshold := 64

# -
# used without a patrol path
export var max_turn_deg := 20.0 # left or right
onready var max_turn := deg2rad(max_turn_deg)
export var turn_rate_deg := 20.0 # per second
onready var turn_rate := deg2rad(turn_rate_deg)

var is_turning_left: bool
var current_base_angle: float
var current_total_turn: float

export var turn_memory_time := 0.2

## allows enemies to override movement stats values while an enemy is idle
## (eg moving slower when the player isn't visible)
## if none given, will use enemy's regular stats
onready var patrol_movement_stats := MovementStats.get_movement_stats(self)


func _ready() -> void:
	patrol_path = PatrolPath.get_patrol_path(owner)
	if patrol_path:
		# warning-ignore:return_value_discarded
		timer.connect("timeout", self, "target_next_point")


## stop moving, then implement the appropriate idle behavior
## assumes called during physics process
# NOTE: passing these params here feels gross
func idle(enemy: Unit, mover: EnemyMover, movement_stats: MovementStats):
	if patrol_movement_stats:
		movement_stats = patrol_movement_stats
	if patrol_path:
		idle_patrol(enemy, mover, movement_stats)
	else:
		idle_turn(enemy, mover, movement_stats)


# -
# with patrol path
# -


## move until reaching the current patrol point, then update to the next point
## oh god this method is a huge mess now
func idle_patrol(enemy: Unit, mover: EnemyMover, movement_stats: MovementStats):
	var was_point_reached := false
	var was_moved := false

	if not is_waiting_for_next_point:
		was_point_reached = enemy.global_position.distance_to(patrol_path.current_point) <= patrol_point_distance_threshold

		if not was_point_reached:
			was_point_reached = mover.move_to(
				enemy,
				movement_stats,
				patrol_path.current_point
			)
			was_moved = true

		if was_point_reached and (not is_waiting_for_next_point) and (not patrol_path.has_single_point):
				is_waiting_for_next_point = true
				timer.start(next_point_wait_time)

	if not was_moved:
		# warning-ignore:return_value_discarded
		mover.apply_friction(movement_stats)
		mover.move_subject(enemy, movement_stats)

	var look_towards_point: Vector2

	if was_point_reached and patrol_path.has_single_point:
		# not sure why the x val has to be this big but it works
		look_towards_point = Vector2(900000, 0).rotated(enemy.initial_rotation)
	else:
		look_towards_point = patrol_path.current_point

	mover.look_towards(
		enemy,
		movement_stats,
		look_towards_point
	)


func target_next_point():
	is_waiting_for_next_point = false
	patrol_path.next_point()


# -
# without patrol path
# -


## look back and forth in place
func idle_turn(enemy: Unit, mover: EnemyMover, movement_stats: MovementStats):
	var speed := mover.apply_friction(movement_stats)
	mover.move_subject(enemy, movement_stats)

	if speed != 0:
		return

	# resets base angle after stopping movement
	if turn_should_reset():
		current_base_angle = enemy.rotation
		is_turning_left = false
		current_total_turn = max_turn / 2 # the base angle is the MIDDLE of the turn

	# apply rotation
	var this_frame_rotation: float = (turn_rate * get_physics_process_delta_time())
	enemy.rotate(this_frame_rotation * (-1 if is_turning_left else 1))

	# check if we should start turning in the other direction
	current_total_turn += this_frame_rotation
	if current_total_turn >= max_turn:
		is_turning_left = !is_turning_left
		current_total_turn = 0


## updates the memory timer.
## if the timer was stopped before updating, return true, else false
func turn_should_reset() -> bool:
	var was_stopped = timer.is_stopped()
	timer.start(turn_memory_time)
	return was_stopped


