extends Action
class_name ShurikenAction
## launches a shuriken projectile that moves like a boomerang and chases the
## player


export(PackedScene) var projectile_scene


func do_action():
	var projectile = projectile_scene.instance()
	projectile.target = user
	Spawner.spawn_node(
		projectile,
		global_position
	)
	projectile.launch(TargetReticle.get_true_global_position())
