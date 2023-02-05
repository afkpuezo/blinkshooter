extends Node2D
class_name GibletAnimator
## creates some particles when a unit dies

# vars

export(PackedScene) var particle_scene

export var min_num_particles := 3
export var max_num_particles := 6

export var min_move_speed := 300
export var max_move_speed := 800

# range should be >= 0, final speed can be negative
export var min_rotation_speed_deg := 0
export var max_rotation_speed_deg := 360

# should it allow for other colors?
export var min_red_modulation := 0
export var max_red_modulation := 0

# methods

func _ready() -> void:
	randomize()


func on_death():
	# random particles
	var num_particles: int = custom_randi_range(min_num_particles, max_num_particles)

	for _x in range(num_particles):
		var particle = particle_scene.instance()
		if particle.has_method("configure_particle"):
			var move_speed = custom_randi_range(min_move_speed, max_move_speed)
			var rotation_speed_deg = custom_randi_range(min_rotation_speed_deg, max_rotation_speed_deg)

			# have to change the other color levels too
			var red_level = custom_randi_range(min_red_modulation, max_red_modulation)
			var bg_level = 255 - red_level
			var modulation = Color8(
				255,
				bg_level,
				bg_level
			)

			particle.configure_particle(
				move_speed,
				rotation_speed_deg,
				modulation
			)

		Spawner.spawn_node(
			particle,
			global_position,
			rand_range(0.0, 2 * PI)
		)


func custom_randi_range(a, b):
	assert(b > a, "b must be greater than a!")
	return a + randi() % (b + 1 - a)
