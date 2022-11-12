extends Mover
class_name ShurikenMover
## moves the user towards the player that launched it
## could be re-purposed for other things in the future


## called once when the shuriken is spawned, immediately moves to max speed
func launch_towards(unit, movement_stats: MovementStats, target_position):
	movement_stats.velocity = \
		movement_stats.MAX_SPEED * unit.position.direction_to(target_position)
	unit.move_and_slide(movement_stats.velocity)


## accelerates the unit towards the target
func chase(unit, movement_stats: MovementStats, target_position):
	accelerate_towards(
		movement_stats,
		get_physics_process_delta_time(),
		unit.position.direction_to(target_position.position)
	)
	unit.move_and_slide(movement_stats.velocity)
