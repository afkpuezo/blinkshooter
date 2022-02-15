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
	var target_position = TargetReticle.get_true_global_position()
	var distance = user.position.distance_to(target_position)
	if distance < MAX_RANGE:
		user.position = target_position
	else:
		print("too far!")
