extends Node2D
class_name Pusher
## pushes a target (Unit?) when prompted - target must have a MovementStats
## The direction of the push is AWAY from the position of this node (or towards
## with a negative strength)
# NOTE: no idea what folder this should go in


export var strength := 100.0
export var start_distance_falloff := 0.0
export var end_distance_falloff := 100.0
onready var falloff_distance_difference = end_distance_falloff - start_distance_falloff


func push(target: Node2D, custom_strength := strength):
	var movement_stats := MovementStats.get_movement_stats(target)

	var force: Vector2 = global_position.direction_to(target.global_position) * custom_strength
	var distance_modifier = calculate_distance_modifier(target.global_position)
	# doing it this way works for push and pull
	force -= force * distance_modifier

	movement_stats.apply_outside_force(force)


func calculate_distance_modifier(target_position: Vector2) -> float:
	var distance := global_position.distance_to(target_position)

	if distance <= start_distance_falloff:
		return 0.0
	elif distance >= end_distance_falloff:
		return 1.0
	else:
		return (distance - start_distance_falloff) / falloff_distance_difference
