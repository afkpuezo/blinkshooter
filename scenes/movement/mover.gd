extends Node2D
class_name Mover
## Movers are used by Units to control their movement.
## This base version won't add any movement, but the class can be extended.


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
## movement (eg, KinematicBody2Ds move_and_slide)
## If the subject is currently over its max speed (eg from being pushed), it
## will gradually slow down until reaching the max speed (using friction)
func move_subject(subject, movement_stats: MovementStats):
	if movement_stats.velocity.length() > movement_stats.max_speed:
		var resulting_speed = max(apply_friction(movement_stats), movement_stats.max_speed)
		movement_stats.velocity = movement_stats.velocity.normalized() * resulting_speed

	if subject is KinematicBody2D:
		subject.move_and_slide(movement_stats.velocity)
	else:
		subject.translate(movement_stats.velocity * get_physics_process_delta_time())
