extends State
# no class_name
## Controls the reticle with mouse input


# ----------
# virtual methods from State
# ----------


## check to see if controller has been moved
func physics_update(_delta: float) -> void:
	if _get_reticle_input():
		emit_signal("state_change_triggered", "Controller")


## configure mouse cursor
func enter(_msg := {}) -> void:
	Input.set_custom_mouse_cursor(
			owner.cursor_image,
			0,
			Vector2(owner.cursor_image.get_width() / 2, owner.cursor_image.get_height() / 2))
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)


## disable mouse cursor
func exit() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)


# ----------
# 'virtual' methods from for Reticle
# ----------


## return mouse position
func get_true_global_position() -> Vector2:
	return owner.get_global_mouse_position()


# ----------
# Mouse state specific methods
# ----------


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
