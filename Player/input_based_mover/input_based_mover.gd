extends Node
class_name InputBasedMover
## TODO: a better name lol
## Listens to a particular input axis and moves this node's owner accordingly.
## Gets the movement stats (max speed, etc) from the owner
## Assumes owner is a KinematicBody2D
## TODO: create movement_stats node?


export var input_axis: String = "ui"
var _dir_strings: Array ## right, left, down, up
onready var _stats: MovementStats = owner.get_node("MovementStats")


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
func physics_update(delta: float) -> void:
	var input := _get_input()

	if input:
		_stats.velocity = \
				_stats.velocity.move_toward(input * _stats.MAX_SPEED, _stats.ACCELERATION * delta)
	else:
		_stats.velocity = \
				_stats.velocity.move_toward(
						Vector2.ZERO,
						max(
								_stats.FRICTION * _stats.velocity.length(),
								1)) # fixes very slow friction at low speeds
	_stats.velocity = owner.move_and_slide(_stats.velocity)
	print("player speed: " + str(_stats.velocity.length()))


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
