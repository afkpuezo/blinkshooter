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

export var max_push_strength := 300
export var min_push_strength := 100
onready var push_strength_range := max_push_strength - min_push_strength


func _ready() -> void:
	randomize() # is it bad to call this a lot


func _on_Enemy_died() -> void:
	if is_enemy_blocked():
		return

	var dropped_pickups := []
	var num_pickups := 0

	for _n in range(num_rolls):
		for type in types_to_chances:
			if LevelGlobal.is_loot_type_enabled(type) and roll(types_to_chances[type] * LevelGlobal.drop_chance_multiplier):
				var p: Pickup = pickup_scene.instance()
				var size = Pickup.SIZE.LARGE if roll(large_ammo_pickup_chance) else Pickup.SIZE.NORMAL
				p.configure(type, size)
				dropped_pickups.append(p)
				num_pickups += 1

	if num_pickups == 0:
		return
	elif num_pickups == 1:
		var p: Pickup = dropped_pickups[0]
		Spawner.spawn_node(p, global_position)
	else:
		var angles := get_angles(num_pickups)
		var base_angle := deg2rad(randi() % 360)

		for x in range(num_pickups):
			var p: Pickup = dropped_pickups[x]
			var angle_delta: float = angles[x]
			var total_angle = base_angle + angle_delta

			Spawner.spawn_node(p, global_position)
			var push_strength = min_push_strength + (randi() % push_strength_range)
			var push_force = Vector2(1, 0).rotated(total_angle) * push_strength
			call_deferred("push_pickup", p, push_force)


func roll(chance) -> bool:
	var r = randi() % 100
	return r < chance


# splits each pickup evenly
func get_angles(num_angles: int) -> Array:
	var current_angle := 0.0
	var angle_delta: float = (PI * 2.0) / num_angles
	var angles := []

	for _n in range(num_angles):
		angles.append(current_angle)
		current_angle += angle_delta

	return angles


func push_pickup(p: Pickup, push_force: Vector2):
	var stats := MovementStats.get_movement_stats(p)
	stats.apply_outside_force(push_force)


func is_enemy_blocked() -> bool:
	return owner.has_node("LootBlocker")
