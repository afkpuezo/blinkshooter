extends Mover
class_name ShurikenMover
## moves the user towards the player that launched it
## could be re-purposed for other things in the future


signal collided(col)

var MIN_LAUNCH_SPEED := 0


## launches at a speed calculated to reach the to point at about the
## duration time. speed is capped at MAX_SPEED
func launch_towards(
	unit,
	movement_stats: MovementStats,
	target_position: Vector2,
	duration: float
	):
	# calculate the speed based on ditance and duration
	var distance = unit.position.distance_to(target_position)
	# account for acceleration in the opposite direction
	var launch_speed = (distance / duration) + (movement_stats.ACCELERATION * duration * 0.5)
	launch_speed = clamp(MIN_LAUNCH_SPEED, launch_speed, movement_stats.MAX_SPEED)
	print("distance and launch_speed: %d, %d" % [distance, launch_speed])

	movement_stats.velocity = launch_speed * unit.position.direction_to(target_position)
	var col = unit.move_and_collide(movement_stats.velocity * get_physics_process_delta_time())
	_handle_collision(col)


## accelerates the unit towards the target
func chase(unit, movement_stats: MovementStats, target_position, should_accelerate := true):
	var delta = get_physics_process_delta_time()
	if should_accelerate:
		accelerate_towards(
			movement_stats,
			delta,
			unit.position.direction_to(target_position)
		)
	var col = unit.move_and_collide(movement_stats.velocity * delta)
	_handle_collision(col)


func _handle_collision(col: KinematicCollision2D):
	if col:
		emit_signal("collided", col)
