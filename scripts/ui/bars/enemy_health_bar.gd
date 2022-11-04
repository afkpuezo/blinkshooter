extends Node2D
class_name EnemyHealthBar
## moves a little resource bar around an assigned enemy

var enemy
onready var bar = $HealthBar
#onready var vis = $VisibilityNotifier2D


## should be called when this is created
func assign_enemy(e):
	enemy = e
	# to follow an enemy
	enemy.connect("died", self, "on_enemy_died")
	var hp: CombatResource = CombatResource.get_resource(enemy, CombatResource.Type.HEALTH)
	if hp:
		# warning-ignore:return_value_discarded
		hp.connect("value_changed", bar, "change_value")
	# to control visibility on first frame
	if not $VisibilityNotifier2D.visible:
		on_not_visible()


## moves to follow the enemy
func _process(_delta: float) -> void:
	global_position = enemy.global_position


func on_enemy_died():
	queue_free()


## won't be safe if called when already visible
func on_visible(_viewport = null):
	#print("ON")
	bar.visible = true
	#add_child(bar)


## won't be safe if called when already not visible
func on_not_visible(_viewport = null):
	#print("OFF")
	bar.visible = false
	#remove_child(bar)


