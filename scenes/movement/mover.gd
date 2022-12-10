extends Node2D
class_name Mover
## Movers are used by Units to control their movement.
## This base version won't add any movement, but the class can be extended.


## Helper method, can be used in physics update, accelerates the unit in the
## given (normalized) direction. Updates the unit's velocity, does not actually
## call move_and_slide.
func accelerate_towards(movement_stats: MovementStats, delta: float, direction: Vector2):
	movement_stats.velocity = \
			movement_stats.velocity.move_toward(direction * movement_stats.max_speed, movement_stats.acceleration * delta)


## Helper method, can be used in physics update, decelerates the unit using
## friction. Updates the unit's velocity, does not actually
## call move_and_slide.
func apply_friction(movement_stats: MovementStats):
	var multiplier: float = movement_stats.friction_percent * get_physics_process_delta_time()
	movement_stats.velocity -= movement_stats.velocity * multiplier
	if movement_stats.velocity.length() < 10:
		movement_stats.velocity = Vector2.ZERO


## helper method called to actually move the subject unit of a specific
## mover
## determines the type of the subject in order to apply the correct kind of
## movement (eg, KinematicBody2Ds move_and_slide)
func move_subject(subject, velocity: Vector2):
	if subject is KinematicBody2D:
		subject.move_and_slide(velocity)
	else:
		subject.translate(velocity * get_physics_process_delta_time())
