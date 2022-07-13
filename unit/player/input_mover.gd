extends Node
class_name InputMover
## TODO: a better name lol
## Listens to a particular input axis and moves this node's owner accordingly.
## Gets the movement stats (max speed, etc) from the owner
## Assumes owner is a KinematicBody2D


export var input_axis: String = "ui"
var _dir_strings: Array ## right, left, down, up
#onready var stats: MovementStats = owner.get_node("MovementStats")


func _ready() -> void:
	# build strings
	var template := "%s_{dir}" % input_axis
	var dirs := ["right", "left", "down", "up"]
	_dir_strings = []
	for dir in dirs:
		_dir_strings.append(template.format({'dir': dir}))


# ----------
# public methods
# ----------


## Called during owner's _physics_process
func physics_update(unit, movement_stats: MovementStats, delta: float):
	var input := _get_input()

	if input:
		movement_stats.velocity = \
				movement_stats.velocity.move_toward(input * movement_stats.MAX_SPEED, movement_stats.ACCELERATION * delta)
	else:
		movement_stats.velocity = \
				movement_stats.velocity.move_toward(
						Vector2.ZERO,
						max(
								movement_stats.FRICTION * movement_stats.velocity.length(),
								1)) # fixes very slow friction at low speeds
	#stats.velocity = owner.move_and_slide(stats.velocity)
	#unit.move_and_collide(movement_stats.velocity * delta)
	unit.move_and_slide(movement_stats.velocity)


# ----------
# private methods
# ----------


## sums up input into a vector
func _get_input() -> Vector2:
	var input = Vector2(
		Input.get_action_strength(_dir_strings[0]) - Input.get_action_strength(_dir_strings[1]),
		Input.get_action_strength(_dir_strings[2]) - Input.get_action_strength(_dir_strings[3])
	)
	if input.length_squared() > 1: # squared is apparently faster
		return input.normalized()
	else:
		return input
