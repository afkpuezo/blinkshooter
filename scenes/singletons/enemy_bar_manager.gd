extends Node2D
#class_name EnemyHealthBarsManager # no need for class name for a singleton
## responsible for attaching health bars to enemies when they spawn.


var ehp_scene = load("res://scenes/ui/bars/enemy_health_bar.tscn")


func _ready() -> void:
	# warning-ignore:return_value_discarded
	GameEvents.connect("enemy_spawned", self, "handle_enemy_spawn")


func handle_enemy_spawn(args):
	var ehp: EnemyHealthBar = ehp_scene.instance()
	add_child(ehp)
	ehp.assign_enemy(
		args['enemy'],
		args['is_boss']
	)

