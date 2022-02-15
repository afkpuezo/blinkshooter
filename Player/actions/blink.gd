extends Action
class_name Blink
## Teleport the player towards the target reticle


export var MAX_RANGE := 500


# ----------
# virtual method(s) from Action
# ----------


func can_do_action() -> bool:
	return true


func do_action():
	user.global_position = \
			user.global_position.move_towards(TargetReticle.get_true_global_position(), MAX_RANGE)
