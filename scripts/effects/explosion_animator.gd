extends Node2D
class_name ExplosionAnimator
## helper scene for creating explosions for bullets, death, attacks, etc

# these vars configure the explosions created by this scene
export(String, "white", "green", "red") var explosion_color = "white"
export(String, "small", "medium", "normal") var explosion_size = "normal"
export(String, "normal", "fast") var explosion_speed = "normal"

export(PackedScene) var explosion_scene


func create_explosion(explosion_position := global_position):
	var explosion = explosion_scene.instance()
	explosion.set_explosion_mode(
		explosion_color,
		explosion_size,
		explosion_speed
	)

	Spawner.spawn_node(explosion, explosion_position)
