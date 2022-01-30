extends KinematicBody2D
class_name Reticle
## reticle used for player aiming
## should respond to mouse and/or controller input
## technically only for gameplay, not menus?


enum ReticleState {MOUSE, CONTROLLER, DISABLED}

var current_state = ReticleState.DISABLED
onready var sprite := $Sprite
onready var cursor_image = sprite.texture

export var MAX_SPEED := 800
var velocity := Vector2.ZERO
var is_mouse_moving := false


func _ready() -> void:
	change_state(ReticleState.MOUSE)


## determine reticle position and state
## should this just be _process?
func _physics_process(delta: float) -> void:
	match current_state:
		ReticleState.MOUSE:
			_process_mouse_state()
		ReticleState.CONTROLLER:
			_process_controller_state(delta)
		ReticleState.DISABLED:
			pass


## potentially unnecessary match method
func change_state(new_state):
	match new_state:
		ReticleState.MOUSE:
			_enter_mouse_state()
		ReticleState.CONTROLLER:
			_enter_controller_state()
		ReticleState.DISABLED:
			pass


func _enter_mouse_state():
	current_state = ReticleState.MOUSE
	Input.set_custom_mouse_cursor(cursor_image, 0, Vector2(16, 16))
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	sprite.visible = false


## stay in mouse state until right stick is moved
func _process_mouse_state():
	if _get_reticle_input():
		change_state(ReticleState.CONTROLLER)


func _enter_controller_state():
	current_state = ReticleState.CONTROLLER
	.set_global_position(get_global_mouse_position())
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	sprite.visible = true
	is_mouse_moving = false


## stay in controller state until mouse is moved
## move reticle according to right stick
func _process_controller_state(delta: float):
	if is_mouse_moving:
		change_state(ReticleState.MOUSE)
		return
	velocity = _get_reticle_input() * MAX_SPEED
	move_and_slide(velocity)


## sums up right stick input
func _get_reticle_input() -> Vector2:
	var input_vector = Vector2.ZERO
	input_vector.x = \
			Input.get_action_strength("ui_reticle_right") \
			- Input.get_action_strength("ui_reticle_left")
	input_vector.y = \
			Input.get_action_strength("ui_reticle_down") \
			- Input.get_action_strength("ui_reticle_up")
	return input_vector.normalized()


# tracks if mouse is moving
func _input(event):
	if event is InputEventMouseMotion and event.relative:
		is_mouse_moving = true
