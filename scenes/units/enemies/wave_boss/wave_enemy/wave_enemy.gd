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

# NOTE: i'm not sure if these should be constants or exports or what
export(PackedScene) var teleport_effect_scene
export(PackedScene) var small_gun_enemy_scene
export(PackedScene) var shotgun_enemy_scene
export(PackedScene) var plasma_enemy_scene
export(PackedScene) var sniper_enemy_scene

# NOTE: i'm not sure if these should be constants or exports or what
const SMALL_GUN_EFFECT_SCALE := 1.0
const SHOTGUN_EFFECT_SCALE := 1.0
const PLASMA_EFFECT_SCALE := 1.25
const SNIPER_EFFECT_SCALE := 2.0


## called from outside
## the player param (can be null) is passed to the enemy so that they can spawn
## with knowledge of the player
# janky to pass reference to the wave manager, but passing a reference to the
# player can cause a crash if the player is freed
# can't refer to the WaveManager class directly cuz dumb
func trigger(wave_manager, extra_delay := 0.0):
	var total_overall_delay := base_overall_delay + extra_delay

	if total_overall_delay > 0.0:
		overall_delay_timer.start(base_overall_delay)
		yield(overall_delay_timer, "timeout")

	var enemy_scene: PackedScene
	var effect_scale: float

	match enemy_type:
		ENEMY_TYPE.SMALL_GUN:
			enemy_scene = small_gun_enemy_scene
			effect_scale = SMALL_GUN_EFFECT_SCALE
		ENEMY_TYPE.SHOTGUN:
			enemy_scene = shotgun_enemy_scene
			effect_scale = SHOTGUN_EFFECT_SCALE
		ENEMY_TYPE.PLASMA:
			enemy_scene = plasma_enemy_scene
			effect_scale = PLASMA_EFFECT_SCALE
		ENEMY_TYPE.SNIPER:
			enemy_scene = sniper_enemy_scene
			effect_scale = SNIPER_EFFECT_SCALE

	var effect: Node2D = teleport_effect_scene.instance()
	effect.scale *= effect_scale

	Spawner.spawn_node(effect, global_position)

	if unit_delay > 0.0:
		unit_delay_timer.start(unit_delay)
		yield(unit_delay_timer, "timeout")

	# if we know about the player, point the enemy at them
	var enemy_rotation: float
	if wave_manager.player:
		enemy_rotation = global_position.angle_to_point(wave_manager.player.global_position) - PI
	else:
		enemy_rotation = global_rotation

	var enemy: Unit = enemy_scene.instance()
	Spawner.spawn_node(enemy, global_position, enemy_rotation)
	# warning-ignore:return_value_discarded
	enemy.connect("died", self, "_on_enemy_death")

	var enemy_brain: EnemyBrain = enemy.get_node("EnemyBrain")
	enemy_brain.call_deferred("do_teleport_animation")
	if wave_manager.player:
		enemy_brain.call_deferred(
			"receive_enemy_message",
			{'player': wave_manager.player}
		)


func _on_enemy_death():
	emit_signal("died")
	queue_free()
