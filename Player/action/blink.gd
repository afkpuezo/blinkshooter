extends Action
class_name Blink
## Teleport the player towards the target reticle


export var MAX_RANGE := 500
export(PackedScene) var effect_scene


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
	if effect_scene:
		GameSpawner.spawn_node(effect_scene.instance(), user.position)
		GameSpawner.spawn_node(effect_scene.instance(), target_position)
	user.do_teleport_animation()
	_wait(0.25)

	user.position = target_position # should this be global position?

func _wait(time: float):
	var t = Timer.new()
	t.set_wait_time(time)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	yield(t, "timeout")
	t.queue_free()
