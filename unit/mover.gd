extends Node
class_name Mover
## Movers are used by Units to control their movement.
## This base version won't add any movement, but the class can be extended.


## The given unit should be the user/owner of this Mover.
## That unit should call this method during it's _physics_update() method.
func physics_update(unit: Unit, movement_stats: MovementStats, delta: float):
	unit.move_and_collide(Vector2.ZERO)
