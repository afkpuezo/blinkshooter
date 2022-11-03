extends Node2D
class_name EnemyHealthBar
## moves a little resource bar around an assigned enemy

var enemy


## should be called when this is created
func assign_enemy(e):
	enemy = e
	enemy.connect("died", self, "on_enemy_died")
	var hp: CombatResource = CombatResource.get_resource(enemy, CombatResource.Type.HEALTH)
	if hp:
		hp.connect("value_changed", $HealthBar, "change_value")


## moves to follow the enemy
func _process(delta: float) -> void:
	global_position = enemy.global_position


func on_enemy_died():
	queue_free()


