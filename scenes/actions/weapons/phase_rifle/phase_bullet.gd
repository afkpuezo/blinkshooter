extends Bullet
class_name PhaseBullet
## scales up size and damage with distance from user/source


#export var max_sprite_scaling_distance := 500.0
#export var max_damage_scaling_distance := 500.0
export var max_scaling_distance := 500.0
export var distance_unit := 100.0 # increase size/damage by base every X distance

onready var initial_damage = damage


func _physics_process(delta: float) -> void:
	var distance := min(
		global_position.distance_to(source.global_position),
		max_scaling_distance
	)
	var multiplier := distance / distance_unit

	scale = Vector2(multiplier, multiplier)
	damage = initial_damage * multiplier
