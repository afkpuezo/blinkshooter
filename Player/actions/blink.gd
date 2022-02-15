extends Action
class_name Blink
## Teleport the player towards the target reticle


export var MAX_RANGE := 500


# ----------
# virtual method(s) from Action
# ----------


func can_do_action() -> bool:
	return true


## Teleport at most MAX_RANGE towards the target
func do_action():
	var target_position = TargetReticle.get_true_global_position()
	var distance = user.position.distance_to(target_position)
	if distance > MAX_RANGE:
		# go as far as we can
		var direction: Vector2 = \
				user.position.direction_to(target_position).normalized()
		target_position = user.position + (direction * MAX_RANGE)
	user.position = target_position # should this be global position?
