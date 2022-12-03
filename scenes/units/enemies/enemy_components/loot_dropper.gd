extends Node2D
class_name LootDropper
## when the enemy dies, has a chance to drop pickups
## Note: each type is rolled seperately, so multiple pickups could be dropped


export(int, 0, 100) var health_chance = 0
export(int, 0, 100) var energy_chance = 0
export(int, 0, 100) var basic_ammo_chance = 0
export(int, 0, 100) var big_ammo_chance = 0

onready var types_to_chances := {
	Pickup.TYPE.BASIC_AMMO: basic_ammo_chance,
	Pickup.TYPE.BIG_AMMO: big_ammo_chance,
	Pickup.TYPE.HEALTH: health_chance,
	Pickup.TYPE.ENERGY: energy_chance,
}

export var max_drop_radius := 96

export(PackedScene) var pickup_scene


func _ready() -> void:
	randomize() # is it bad to call this a lot


func _on_Enemy_died() -> void:
	for type in types_to_chances:
		if roll(types_to_chances[type]):
			var p: Pickup = pickup_scene.instance()
			p.type = type
			Spawner.spawn_node(p, get_random_spawn_position())


func roll(c) -> bool:
	var r = randi() % 100
	return r < c


## returns a random position within the drop radius
func get_random_spawn_position() -> Vector2:
	var distance = randi() % max_drop_radius
	var spawn_pos = Vector2(distance, 0)
	var deg = randi() % 360
	spawn_pos = spawn_pos.rotated(deg2rad(deg))
	spawn_pos = spawn_pos + global_position
	return spawn_pos
