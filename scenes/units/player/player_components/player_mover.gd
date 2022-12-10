extends Mover
class_name PlayerMover
## TODO: a better name lol
## Listens to a particular input axis and moves this node's owner accordingly.
## Gets the movement stats (max speed, etc) from the owner
## Assumes owner is a KinematicBody2D


export var input_axis: String = "ui"
var _dir_strings: Array ## right, left, down, up


func _ready() -> void:
	# build strings
	var template := "%s_{dir}" % input_axis
	var dirs := ["right", "left", "down", "up"]
	_dir_strings = []
	for dir in dirs:
		_dir_strings.append(template.format({'dir': dir}))


## Called during owner's _physics_process
func physics_update(unit, movement_stats: MovementStats):
	var input := get_input()

	if input:
		accelerate_towards(movement_stats, get_physics_process_delta_time(), input)
	else: # if no player found
		apply_friction(movement_stats)
	move_subject(unit, movement_stats)
	unit.look_at(TargetReticle.get_true_global_position())


# ----------
# player-specific helper methods
# ----------


## sums up input into a vector
func get_input() -> Vector2:
	var input = Vector2(
		Input.get_action_strength(_dir_strings[0]) - Input.get_action_strength(_dir_strings[1]),
		Input.get_action_strength(_dir_strings[2]) - Input.get_action_strength(_dir_strings[3])
	)
	if input.length_squared() > 1: # squared is apparently faster
		return input.normalized()
	else:
		return input

