extends Node2D
class_name WaveEnemy
## represents a single enemy that will be spawned as part of a wave


signal died()


onready var overall_delay_timer: Timer = $OverallDelayTimer
export var base_overall_delay := 0.0 # time between trigger call and start of spawning
onready var unit_delay_timer: Timer = $UnitDelayTimer
export var unit_delay := 0.25 # time between teleport effect and enemy spawn

enum ENEMY_TYPE{SMALL_GUN, SHOTGUN, PLASMA, SNIPER}
export(ENEMY_TYPE) var enemy_type := ENEMY_TYPE.SMALL_GUN

export(PackedScene) var teleport_effect_scene
export(PackedScene) var small_gun_enemy_scene
export(PackedScene) var shotgun_enemy_scene
export(PackedScene) var plasma_enemy_scene
export(PackedScene) var sniper_enemy_scene


## very silly optimization
func get_scene() -> PackedScene:
	var scene: PackedScene

	match enemy_type:
		ENEMY_TYPE.SMALL_GUN:
			scene = small_gun_enemy_scene
		ENEMY_TYPE.SHOTGUN:
			scene = shotgun_enemy_scene
		ENEMY_TYPE.PLASMA:
			scene = plasma_enemy_scene
		ENEMY_TYPE.SNIPER:
			scene = sniper_enemy_scene

	return scene


## called from outside
func trigger(extra_delay := 0.0):
	var total_overall_delay := base_overall_delay + extra_delay

	if total_overall_delay > 0.0:
		overall_delay_timer.start(base_overall_delay)
		yield(overall_delay_timer, "timeout")

	Spawner.spawn_node(teleport_effect_scene.instance(), global_position)

	if unit_delay > 0.0:
		unit_delay_timer.start(unit_delay)
		yield(unit_delay_timer, "timeout")

	var enemy_scene: PackedScene = get_scene()
	var enemy: Unit = enemy_scene.instance()
	Spawner.spawn_node(enemy, global_position, global_rotation)
	enemy.connect("died", self, "_on_enemy_death")


func _on_enemy_death():
	emit_signal("died")
	queue_free()
