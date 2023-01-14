extends Node2D
class_name Reticle
## used to have controller support, keep this around because of spaghetti code


## returns the current 'true' position of the reticle
## needed because the actual reticle does not move while in MOUSE mode
func get_true_global_position() -> Vector2:
	return get_global_mouse_position()

