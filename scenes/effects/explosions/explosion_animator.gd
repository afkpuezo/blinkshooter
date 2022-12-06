extends Node2D
class_name ExplosionAnimator
## helper scene for creating explosions for bullets, death, attacks, etc

export(PackedScene) var explosion_scene

# these vars configure the explosions created by this scene
export(String, "white", "green", "red", "orange") var explosion_color = "white"
export var explosion_scale: float = 1.0
export var explosion_speed := 1.0

export(String, "0", "5", "random") var sprite_z = "random"


func _ready() -> void:
	randomize()


func create_explosion(explosion_position := global_position):
	var explosion: Explosion = explosion_scene.instance()
	explosion.set_explosion_color(explosion_color)
	explosion.scale *= explosion_scale
	explosion.anim_speed = explosion_speed
	explosion.z_index = _get_sprite_z()

	Spawner.spawn_node(explosion, explosion_position)


func _get_sprite_z() -> int:
	if sprite_z == "random":
		var temp_z = (randi() % 2) * 5
		return temp_z
	else:
		return int(sprite_z)
