extends AreaOverTimeAttack
tool # for warning icon
class_name ContactAttack
## Used for hurting the player when they touch an enemy
# NOTE: there's some repeated code from SawBladeAttack, might want to fix
# later?


signal hit_at(hit_pos)


export var hit_radius := 32 # determines where explosion is drawn


func _get_configuration_warning():
	for c in get_children():
		if c is HitBox:
			return ""
	return "Requires HitBox"


func _ready() -> void:
	# warning-ignore:return_value_discarded
	connect("dealt_damage", self, "on_dealing_damage")


func on_dealing_damage(victim: Unit, _amount):
	emit_signal(
		"hit_at",
		calculate_hit_position(victim.global_position)
	)


## figure out where to place the hit explosion for this enemy
func calculate_hit_position(victim_global_position: Vector2) -> Vector2:
	var direction = global_position.direction_to(victim_global_position)
	return global_position + (direction * hit_radius)

