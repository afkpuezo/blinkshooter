extends Node2D
class_name ExplosionAnimator
## helper scene for creating explosions for bullets, death, attacks, etc

export(PackedScene) var explosion_scene

# these vars configure the explosions created by this scene
export(String, "white", "green", "red") var explosion_color = "white"
export(String, "tiny", "small", "medium", "normal") var explosion_size = "normal"
export(String, "normal", "fast") var explosion_speed = "normal"

export(String, "0", "5", "random") var sprite_z = "random"


func _ready() -> void:
	randomize()


func create_explosion(explosion_position := global_position):
	var explosion = explosion_scene.instance()
	explosion.set_explosion_mode(
		explosion_color,
		explosion_size,
		explosion_speed
	)
	explosion.z_index = _get_sprite_z()

	Spawner.spawn_node(explosion, explosion_position)


func _get_sprite_z() -> int:
	if sprite_z == "random":
		var temp_z = (randi() % 2) * 5
		return temp_z
	else:
		return int(sprite_z)
