extends State
# no class_name
## controls the reticle with controller right stick input


var _is_mouse_moving := false
var _last_valid_position = Vector2.ZERO
onready var input_mover: InputMover = $InputMover
onready var _owner_movement_stats: MovementStats = owner.get_node("MovementStats")


# ----------
# virtual methods from State
# ----------


## check to see if mouse has been moved
func physics_update(delta: float) -> void:
	if _is_mouse_moving:
		emit_signal("state_change_triggered", "Mouse")
		return

	if not owner.is_within_screen_margin(): # NOTE: assumes owner has this method
		owner.global_position = _last_valid_position
		_owner_movement_stats.velocity = Vector2.ZERO
		return

	_last_valid_position = owner.global_position
	input_mover.physics_update(delta)


## disable mouse cursor and enable sprite
func enter(_msg := {}) -> void:
	owner.global_position = owner.get_global_mouse_position()
	_last_valid_position = owner.global_position
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	owner.sprite.visible = true
	_is_mouse_moving = false


## disable mouse cursor
func exit() -> void:
	owner.sprite.visible = false


# ----------
# 'virtual' methods from for Reticle
# ----------


## return reticle position
func get_true_global_position() -> Vector2:
	return owner.global_position


# ----------
# Controller state specific methods
# ----------


## tracks if mouse is moving
func _input(event):
	if event is InputEventMouseMotion and event.relative:
		_is_mouse_moving = true


## sums up right stick input
## TODO: put in util class static method?
func _get_reticle_input() -> Vector2:
	var input_vector = Vector2.ZERO
	input_vector.x = \
			Input.get_action_strength("ui_reticle_right") \
			- Input.get_action_strength("ui_reticle_left")
	input_vector.y = \
			Input.get_action_strength("ui_reticle_down") \
			- Input.get_action_strength("ui_reticle_up")
	return input_vector.normalized()

