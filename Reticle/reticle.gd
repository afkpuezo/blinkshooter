extends Node2D
class_name Reticle
## reticle used for player aiming
## should respond to mouse and/or controller input
## technically only for gameplay, not menus?


enum ReticleState {MOUSE, CONTROLLER, DISABLED}
var current_state = ReticleState.DISABLED
onready var cursor_image = $Sprite.texture


func _ready() -> void:
	change_state(ReticleState.MOUSE)


## potentially unnecessary match method
func change_state(new_state):
	match new_state:
		ReticleState.MOUSE:
			_enter_mouse_state(new_state)
		ReticleState.CONTROLLER:
			pass
		ReticleState.DISABLED:
			pass


func _enter_mouse_state(new_state):
	Input.set_custom_mouse_cursor(cursor_image)
	current_state = new_state


## determine reticle position and state
## should this just be _process?
func _physics_process(delta: float) -> void:
	match current_state:
		ReticleState.MOUSE:
			_process_mouse_state(delta)
		ReticleState.CONTROLLER:
			pass
		ReticleState.DISABLED:
			pass


func _process_mouse_state(delta: float):
	pass


## sums up right stick input
func _get_reticle_input() -> Vector2:
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	return input_vector.normalized()

