extends KinematicBody2D
class_name Player
## primary player controller


# movement speed values
export var ACCELERATION := 500
export var MAX_SPEED := 100
export(float, 0.0, 1.0) var FRICTION := 0.1 # only applied when no movement input


var velocity := Vector2.ZERO
#var _input_vector := Vector2.ZERO


## currently takes care of movement itself
## will likely get changed to a state machine later
## also controls direction
func _physics_process(delta: float) -> void:
	var _input_vector = Vector2.ZERO
	_input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	_input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	_input_vector = _input_vector.normalized()

	if _input_vector:
		velocity = velocity.move_toward(_input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * velocity.length())
	velocity = move_and_slide(velocity)

	look_at(TargetReticle.get_true_global_position())


## if the new amount is 0, we ded
func _check_for_death(new_health_value) -> void:
	if new_health_value == 0:
		GameEvents.emit_signal("player_died")
		queue_free()
