extends Node2D
class_name EnemyHealthBar
## moves a little resource bar around an assigned enemy

var enemy
onready var bar = $HealthBar
onready var lock_icon = $HealthBar/LockIcon

export var extra_boss_offset := 100
export var extra_boss_height := 10
export var extra_boss_width := 50


## should be called when this is created
func assign_enemy(e: Unit, is_boss: bool):
	if is_boss:
		bar.margin_left -= extra_boss_width
		bar.margin_right += extra_boss_width
		bar.margin_bottom -= extra_boss_offset
		bar.margin_top -= extra_boss_offset + extra_boss_height
		lock_icon.position.x += extra_boss_width * 2

	enemy = e
	# to follow an enemy
	enemy.connect("tree_exiting", self, "on_enemy_died")
	var hp: CombatResource = CombatResource.get_resource(
		enemy,
		CombatResource.Type.HEALTH
	)
	if hp:
		# warning-ignore:return_value_discarded
		hp.connect("value_changed", bar, "change_value")
	# to control visibility on first frame
	if not $VisibilityNotifier2D.visible:
		on_not_visible()

	# if the enemy is blocking a lock, display the icon
	lock_icon.visible = enemy.get_parent() is Lock


## moves to follow the enemy
func _process(_delta: float) -> void:
	global_position = enemy.global_position


func on_enemy_died():
	queue_free()


## won't be safe if called when already visible
func on_visible(_viewport = null):
	visible = true


## won't be safe if called when already not visible
func on_not_visible(_viewport = null):
	visible = false


