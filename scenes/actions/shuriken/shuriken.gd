extends Action
class_name Shuriken
## launches a shuriken projectile that moves like a boomerang and chases the
## player


export(PackedScene) var projectile_scene

## the projectile's speed may be modified in order to reach the original
## mouse cursor location within this time
export var launch_duration := 0.5
export var max_launch_range := 600.0
export var min_launch_range := 64

var spawn_point # bullet spawn point if the user has one


## calling this in ready causes an error, so just call it in do_action()
func _setup_spawn_location():
	if not spawn_point:
		spawn_point = BulletSpawnPoint.get_bullet_spawn_point(user)
		if not spawn_point:
			spawn_point = user


func do_action():
	_setup_spawn_location()
	var projectile = projectile_scene.instance()
	projectile.user = user
	projectile.target = user

	# launch_to must be a minimum away
	var launch_to = get_global_mouse_position()
	var distance = global_position.distance_to(launch_to)
	if distance > max_launch_range:
		var dir = global_position.direction_to(launch_to)
		launch_to = global_position + (dir * max_launch_range)

	projectile.launch_to = launch_to
	projectile.launch_duration = launch_duration

	if user.has_signal("died"):
		# warning-ignore:return_value_discarded
		user.connect("died", projectile, "on_target_death")

	Spawner.spawn_node(
		projectile,
		spawn_point.global_position
	)


func can_do_action() -> bool:
	return user.position.distance_to(get_global_mouse_position()) >= min_launch_range
