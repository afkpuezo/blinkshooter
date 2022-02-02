extends KinematicBody2D
class_name Reticle
## reticle used for player aiming
## should respond to mouse and/or controller input
## technically only for gameplay, not menus?


enum ReticleState {MOUSE, CONTROLLER, DISABLED}

onready var sprite: Sprite = $Sprite
onready var cursor_image = sprite.texture
onready var vis_nodes_array: Array = $VisNodes.get_children()

var current_state = ReticleState.DISABLED
var is_mouse_moving := false
export var SCREEN_MARGIN = 100
export var MAX_SPEED := 800
export var ACCELERATION := 200
export(float, 0.0, 1.0) var FRICTION := 0.1 # only applied when no movement input
var _velocity := Vector2.ZERO
var _last_valid_position = Vector2.ZERO


## start in mouse state (temp)
## place vis nodes
func _ready() -> void:
	change_state(ReticleState.MOUSE)

	vis_nodes_array[0].position = Vector2(position.x, position.y + SCREEN_MARGIN)
	vis_nodes_array[1].position = Vector2(position.x + SCREEN_MARGIN, position.y)
	vis_nodes_array[2].position = Vector2(position.x, position.y - SCREEN_MARGIN)
	vis_nodes_array[3].position = Vector2(position.x - SCREEN_MARGIN, position.y)


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


## returns the current 'true' position of the reticle
## needed because the actual reticle does not move while in MOUSE mode
func get_true_global_position() -> Vector2:
	match current_state:
		ReticleState.MOUSE:
			return(get_global_mouse_position())
		ReticleState.CONTROLLER:
			return global_position
		_:
			return Vector2.ZERO ## TODO handle this


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
	global_position = get_global_mouse_position()
	_last_valid_position = global_position
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	sprite.visible = true
	is_mouse_moving = false


## stay in controller state until mouse is moved
## move reticle according to right stick
func _process_controller_state(delta: float):
	if is_mouse_moving:
		change_state(ReticleState.MOUSE)
		return

	if not _is_within_screen_margin():
		global_position = _last_valid_position
		_velocity = Vector2.ZERO
		return

	_last_valid_position = global_position
	var input := _get_reticle_input()

	if input:
		_velocity = _velocity.move_toward(input * MAX_SPEED, ACCELERATION * delta)
	else: # if no input
		_velocity = _velocity.move_toward(Vector2.ZERO, FRICTION * _velocity.length())
	_velocity = move_and_slide(_velocity)


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


## tracks if mouse is moving
func _input(event):
	if event is InputEventMouseMotion and event.relative:
		is_mouse_moving = true


## checks all vis nodes
func _is_within_screen_margin():
	for vis in vis_nodes_array:
		if not vis.is_on_screen():
			return false
	return true
