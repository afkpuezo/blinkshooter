extends Node2D
class_name WaveEnemy
## represents a single enemy that will be spawned as part of a wave


signal died()


onready var timer: Timer = $Timer

enum ENEMY_TYPE{SMALL_GUN, SHOTGUN, PLASMA, SNIPER}
export(ENEMY_TYPE) var enemy_type := ENEMY_TYPE.SMALL_GUN

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
func trigger(delay := 0.0):
	if delay <= 0.0:
		_spawn_enemy()
	else:
		timer.start(delay)


func _spawn_enemy():
	var scene: PackedScene = get_scene()
	var enemy: Unit = scene.instance()
	Spawner.spawn_node(enemy, global_position, global_rotation)
	enemy.connect("died", self, "_on_enemy_death")


func _on_enemy_death():
	emit_signal("died")
	queue_free()
