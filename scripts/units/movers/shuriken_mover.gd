extends Mover
class_name ShurikenMover
## moves the user towards the player that launched it
## could be re-purposed for other things in the future


signal collided(col)


## called once when the shuriken is spawned, immediately moves to max speed
func launch_towards(unit, movement_stats: MovementStats, target_position):
	movement_stats.velocity = \
		movement_stats.MAX_SPEED * unit.position.direction_to(target_position)
	var col = unit.move_and_collide(movement_stats.velocity * get_physics_process_delta_time())
	_handle_collision(col)


## accelerates the unit towards the target
func chase(unit, movement_stats: MovementStats, target_position):
	var delta = get_physics_process_delta_time()
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
