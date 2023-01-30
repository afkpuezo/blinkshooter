extends Node2D
class_name LootDropper
## when the enemy dies, has a chance to drop pickups
## Note: each type is rolled seperately, so multiple pickups could be dropped


export(int, 0, 100) var health_chance = 10
export(int, 0, 100) var energy_chance = 10
export(int, 0, 100) var basic_ammo_chance = 10
export(int, 0, 100) var plasma_ammo_chance = 10
export(int, 0, 100) var large_ammo_pickup_chance = 30 # for all types

export var num_rolls := 1

onready var types_to_chances := {
	Pickup.TYPE.BASIC_AMMO: basic_ammo_chance,
	Pickup.TYPE.PLASMA_AMMO: plasma_ammo_chance,
	Pickup.TYPE.HEALTH: health_chance,
	Pickup.TYPE.ENERGY: energy_chance,
}
export(PackedScene) var pickup_scene

onready var pusher: Pusher = $Pusher
export var max_push_strength := 300


func _ready() -> void:
	randomize() # is it bad to call this a lot


func _on_Enemy_died() -> void:
	for _n in range(num_rolls):
		for type in types_to_chances:
			if LevelGlobal.is_loot_type_enabled(type) and roll(types_to_chances[type] * LevelGlobal.drop_chance_multiplier):
				var p: Pickup = pickup_scene.instance()
				var size = Pickup.SIZE.LARGE if roll(large_ammo_pickup_chance) else Pickup.SIZE.NORMAL
				p.configure(type, size)
				Spawner.spawn_node(p, get_random_spawn_position())
				pusher.call_deferred("push", p, randi() % max_push_strength)


func roll(chance) -> bool:
	var r = randi() % 100
	return r < chance


## returns a random position within the drop radius
func get_random_spawn_position() -> Vector2:
	var deg = randi() % 360
	var spawn_pos = Vector2(1, 0).rotated(deg2rad(deg))
	spawn_pos += global_position
	return spawn_pos
