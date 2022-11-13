extends Node2D
class_name AreaOverTimeAttack
## Generic version of a damage source that deals damage to all targets in an
## area periodically. Rather than dealing a small amount of damage every frame
## or so, deals damage up front on first contact with a target, then waits for
## a cooldown to pass before damaging that target again. Each target has a
## seperate cooldown

export(PackedScene) var damage_cooldown_scene = load("res://scenes/buffs/damage_cooldown.tscn")

export var damage := 30
export var damage_cooldown := 0.5

onready var hit_box: HitBox = $HitBox # needs one


## Checking collisions happens here because an enemy could stay in the hit box
## and continue to take damage (rather than using an on_entered signal)
func _physics_process(delta: float) -> void:
	handle_damage()


func handle_damage():
	var victim_areas = _get_potential_victims()
	for victim in victim_areas:
		_handle_victim(victim)


func _get_potential_victims() -> Array:
	var areas: Array = hit_box.get_overlapping_areas()

	var victims := []
	for area in areas:
		if area.has_method("get_unit"): # if it's a hurtbox
			victims.append(area.get_unit())

	return victims


## If the victim can take buffs and does not have the DamageCooldown buff for
## the sawblade, deal damage and apply the buff.
func _handle_victim(victim):
	if victim.has_method("get_buffs"):
		var buffs: Array = victim.get_buffs()
		for buff in buffs:
			if buff.get("source") == self:
				return

		# if we got here, we can deal damage
		var dc: DamageCooldown = damage_cooldown_scene.instance()
		dc.setup(self, damage_cooldown)
		victim.add_buff(dc)
		victim.take_damage(damage, owner)


