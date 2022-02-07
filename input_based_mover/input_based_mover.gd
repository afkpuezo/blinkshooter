extends Node
class_name InputBasedMover
## TODO: a better name lol
## Listens to a particular input axis and moves this node's owner accordingly.
## Gets the movement stats (max speed, etc) from the owner
## Assumes owner is a KinematicBody2D
## TODO: create movement_stats node?


export var input_axis: String = "ui"
var _dir_strings: Array ## right, left, down, up


func _ready() -> void:
	# build strings
	var template := "%s_{dir}" % input_axis
	var dirs := ["right", "left", "down", "up"]
	_dir_strings = []
	for dir in dirs:
		_dir_strings.append(template.format({'dir': dir}))
	print("DEBUG: IBM's owner is " + owner.name)


# ----------
# public methods
# ----------


## Called during owner's _physics_process
func physics_update(delta: float) -> void:
	var input := _get_input()

	if input:
		owner.velocity = \
				owner.velocity.move_toward(input * owner.MAX_SPEED, owner.ACCELERATION * delta)
	else:
		owner.velocity = \
				owner.velocity.move_toward(Vector2.ZERO, owner.FRICTION * owner.velocity.length())
	owner.velocity = owner.move_and_slide(owner.velocity)


# ----------
# private methods
# ----------


## sums up input into a vector
func _get_input() -> Vector2:
	return Vector2(
		Input.get_action_strength(_dir_strings[0]) - Input.get_action_strength(_dir_strings[1]),
		Input.get_action_strength(_dir_strings[2]) - Input.get_action_strength(_dir_strings[3])
	)
