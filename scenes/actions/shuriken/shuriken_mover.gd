extends Mover
class_name ShurikenMover
## moves the user towards the player that launched it
## could be re-purposed for other things in the future


var MIN_LAUNCH_SPEED := 0


## launches at a speed calculated to reach the to point at about the
## duration time. speed is capped at max_speed
func launch_towards(
	unit,
	movement_stats: MovementStats,
	target_position: Vector2,
	duration: float
	):
	# calculate the speed based on ditance and duration
	var distance = unit.position.distance_to(target_position)
	# account for acceleration in the opposite direction
	var launch_speed = (distance / duration) + (movement_stats.acceleration * duration * 0.5)
	launch_speed = clamp(MIN_LAUNCH_SPEED, launch_speed, movement_stats.max_speed)

	movement_stats.velocity = launch_speed * unit.position.direction_to(target_position)
	move_subject(
		unit,
		movement_stats
	)
