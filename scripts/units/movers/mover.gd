extends Node2D
class_name Mover
## Movers are used by Units to control their movement.
## This base version won't add any movement, but the class can be extended.


## The given unit should be the user/owner of this Mover.
## That unit should call this method during it's _physics_update() method.
func physics_update(unit, movement_stats: MovementStats, delta: float):
	#print("DEBUG: Mover.physics_update() called")
	unit.move_and_collide(Vector2.ZERO)


## Helper method, can be used in physics update, accelerates the unit in the
## given (normalized) direction. Updates the unit's velocity, does not actually
## call move_and_slide.
func accelerate_towards(unit, movement_stats: MovementStats, delta: float, direction: Vector2):
	movement_stats.velocity = \
			movement_stats.velocity.move_toward(direction * movement_stats.MAX_SPEED, movement_stats.ACCELERATION * delta)

## Helper method, can be used in physics update, decelerates the unit using
## friction. Updates the unit's velocity, does not actually
## call move_and_slide.
func apply_friction(unit, movement_stats: MovementStats, delta: float):
	movement_stats.velocity = \
			movement_stats.velocity.move_toward(
					Vector2.ZERO,
					max(
							movement_stats.FRICTION * movement_stats.velocity.length(),
							1)) # fixes very slow friction at low speeds

