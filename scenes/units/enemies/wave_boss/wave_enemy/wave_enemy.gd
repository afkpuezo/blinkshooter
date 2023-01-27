extends Node2D
class_name WaveEnemy
## represents a single enemy that will be spawned as part of a wave


signal died()


onready var overall_delay_timer: Timer = $OverallDelayTimer
export var base_overall_delay := 0.0 # time between trigger call and start of spawning
onready var unit_delay_timer: Timer = $UnitDelayTimer
export var unit_delay := 0.25 # time between teleport effect and enemy spawn
export var player_awareness_delay := 0.1 # spawning is call_deferred so we need a delay

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
## the player param (can be null) is passed to the enemy so that they can spawn
## with knowledge of the player
func trigger(player: Unit, extra_delay := 0.0):
	var total_overall_delay := base_overall_delay + extra_delay

	if total_overall_delay > 0.0:
		overall_delay_timer.start(base_overall_delay)
		yield(overall_delay_timer, "timeout")

	Spawner.spawn_node(teleport_effect_scene.instance(), global_position)

	if unit_delay > 0.0:
		unit_delay_timer.start(unit_delay)
		yield(unit_delay_timer, "timeout")

	# if we know about the player, point the enemy at them
	var enemy_rotation: float
	if player:
		enemy_rotation = global_position.angle_to_point(player.global_position) - PI
	else:
		enemy_rotation = global_rotation

	var enemy_scene: PackedScene = get_scene()
	var enemy: Unit = enemy_scene.instance()
	Spawner.spawn_node(enemy, global_position, enemy_rotation)
	# warning-ignore:return_value_discarded
	enemy.connect("died", self, "_on_enemy_death")

	var enemy_brain: EnemyBrain = enemy.get_node("EnemyBrain")
	enemy_brain.call_deferred("do_teleport_animation")
	enemy_brain.call_deferred("receive_enemy_message", {'player': player})
#	if player:
#		# spawning is call_deferred so we need a delay
#		unit_delay_timer.start(player_awareness_delay)
#		yield(unit_delay_timer, "timeout")
#		# probably shouldn't hard-code this but who cares at this point
#		var enemy_brain: EnemyBrain = enemy.get_node("EnemyBrain")
#		enemy_brain.do_teleport_animation()
#		enemy_brain.receive_enemy_message({'player': player})


func _on_enemy_death():
	emit_signal("died")
	queue_free()
