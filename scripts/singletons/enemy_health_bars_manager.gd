extends Node2D
class_name EnemyHealthBarsManager
## responsible for attaching health bars to enemies when they spawn.


func _ready() -> void:
	print("EnemyHealthBarsManager.ready()")
	GameEvents.connect("enemy_spawned", self, "handle_enemy_spawn")


func handle_enemy_spawn(args):
	print("EnemyHealthBarsManager.handle_enemy_spawn()")

