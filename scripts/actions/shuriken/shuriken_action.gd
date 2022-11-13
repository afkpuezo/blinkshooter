extends Action
class_name ShurikenAction
## launches a shuriken projectile that moves like a boomerang and chases the
## player


export(PackedScene) var projectile_scene

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
	projectile.launch_to = TargetReticle.get_true_global_position()
	Spawner.spawn_node(
		projectile,
		spawn_point.global_position
	)
