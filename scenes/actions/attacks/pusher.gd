extends Node2D
class_name Pusher
## pushes a target (Unit?) when prompted - target must have a MovementStats
## The direction of the push is AWAY from the position of this node (or towards
## with a negative strength)
# NOTE: no idea what folder this should go in


export var strength := 100.0


## _arg lets this be called by a signal with 1 or 2 args
func push(target: Node2D, _arg = null):
	print("push called")
	var movement_stats := MovementStats.get_movement_stats(target)
	var force: Vector2 = global_position.direction_to(target.global_position) * strength
	movement_stats.apply_outside_force(force)


