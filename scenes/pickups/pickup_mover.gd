extends Mover
class_name PickupMover
## used so that the player can suck up pickups


## called when the pickup is close enough to the player
## updates velocity and does the actual movement
func be_vacuumed(pickup, movement_stats: MovementStats, target_global_pos: Vector2):
	var dir = pickup.global_position.direction_to(target_global_pos)
	accelerate_towards(movement_stats, get_physics_process_delta_time(), dir)
	move_subject(pickup, movement_stats.velocity)


## called when the pickup is NOT close enough to the player
## updates velocity and does the actual movement
func idle(pickup, movement_stats: MovementStats):
	apply_friction(movement_stats)
	move_subject(pickup, movement_stats.velocity)
