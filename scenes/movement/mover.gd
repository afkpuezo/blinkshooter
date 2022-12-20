extends Node2D
class_name Mover
## Movers are used by Units to control their movement.
## This base version won't add any movement, but the class can be extended.


signal collided(col)


# not sure why this is needed but it works so here we go
const LOOK_AT_POINT := Vector2(1, 0)


## Helper method, can be used in physics update, accelerates the unit in the
## given (normalized) direction. Updates the unit's velocity, does not actually
## call move_and_slide.
func accelerate_towards(movement_stats: MovementStats, delta: float, direction: Vector2):
	movement_stats.velocity = movement_stats.velocity.move_toward(
		direction * movement_stats.max_speed,
		movement_stats.acceleration * delta
	)


## Helper method, can be used in physics update, decelerates the unit using
## friction. Updates the unit's velocity, does not actually
## call move_and_slide.
## returns the resulting SPEED
# NOTE: ultra jank
func apply_friction(movement_stats: MovementStats) -> float:
	var multiplier: float = movement_stats.friction * get_physics_process_delta_time()
	var speed := movement_stats.velocity.length()
	# this is so jank
	var slowdown_factor = max(movement_stats.acceleration, max(speed, movement_stats.max_speed))
	speed = speed - (slowdown_factor * multiplier)
	if speed < 10:
		movement_stats.velocity = Vector2.ZERO
		speed = 0
	movement_stats.velocity = movement_stats.velocity.normalized() * speed
	return speed


## helper method called to actually move the subject unit of a specific
## mover
## determines the type of the subject in order to apply the correct kind of
## movement
## get_collision determines if KB2Ds use move_and_collide or move_and_slide
## If the subject is currently over its max speed (eg from being pushed), it
## will gradually slow down until reaching the max speed (using friction)
func move_subject(
	subject: Node2D,
	movement_stats: MovementStats,
	get_collision := false
):
	if movement_stats.velocity.length() > movement_stats.max_speed:
		var resulting_speed = max(apply_friction(movement_stats), movement_stats.max_speed)
		movement_stats.velocity = movement_stats.velocity.normalized() * resulting_speed

	if subject is KinematicBody2D:
		if get_collision:
			var col = subject.move_and_collide(movement_stats.velocity * get_physics_process_delta_time())
			if col:
				emit_signal("collided", col)
			return col
		else:
			subject.move_and_slide(movement_stats.velocity)
	else:
		subject.translate(movement_stats.velocity * get_physics_process_delta_time())
	return null # unnecessary i guess


## used in homing attacks
## accelerates the unit towards the target
func chase(
	subject: Node2D,
	movement_stats: MovementStats,
	target_position: Vector2,
	should_accelerate := true,
	get_collision := false
	):
	var delta = get_physics_process_delta_time()
	if should_accelerate:
		accelerate_towards(
			movement_stats,
			delta,
			subject.position.direction_to(target_position)
		)
	return move_subject(subject, movement_stats, get_collision)


## like the built in look_to, but capped by the unit's max rotation speed
func look_towards(
	subject: Node2D,
	movement_stats: MovementStats,
	target_position: Vector2
):
	var angle_to_target = LOOK_AT_POINT.angle_to(subject.to_local(target_position))
	var max_turn := movement_stats.rotation_speed * get_physics_process_delta_time()
	var final_turn: float

	if angle_to_target < 0:
		final_turn = max(
			angle_to_target,
			max_turn * -1
		)
	else:
		final_turn = min(
			angle_to_target,
			max_turn
		)

	subject.rotate(final_turn)

