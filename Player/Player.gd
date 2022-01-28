extends KinematicBody2D
class_name Player
## Player controller


# movement speed values
export var ACCELERATION := 500
export var MAX_SPEED := 100
export var FRICTION := 600


var velocity := Vector2.ZERO
var _input_vector := Vector2.ZERO


## currently takes care of movement itself
## will likely get changed to a state machine later
func _physics_process(delta: float) -> void:
	_input_vector = Vector2.ZERO
	_input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	_input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	_input_vector = _input_vector.normalized()

	if _input_vector != Vector2.ZERO:
		velocity = velocity.move_toward(_input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	velocity = move_and_slide(velocity)
