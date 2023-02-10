extends Node2D
class_name AreaOverTimeAttack
## Generic version of a damage source that deals damage to all targets in an
## area periodically. Rather than dealing a small amount of damage every frame
## or so, deals damage up front on first contact with a target, then waits for
## a cooldown to pass before damaging that target again. Each target has a
## seperate cooldown


signal dealt_damage(victim, amount)


export(PackedScene) var damage_cooldown_scene = load("res://scenes/buffs/damage_cooldown.tscn")

export var damage := 30
export var damage_cooldown := 0.5

onready var hit_box: HitBox = $HitBox # needs one
var hit_approver: HitApprover

var source # should be set by action/weapon source


func _ready() -> void:
	if has_node("HitApprover"):
		hit_approver = get_node("HitApprover")


## Checking collisions happens here because an enemy could stay in the hit box
## and continue to take damage (rather than using an on_entered signal)
func _physics_process(_delta: float) -> void:
	handle_damage()


func handle_damage():
	var victims = get_potential_victims()
	for victim in victims:
		if get_approval(victim):
			handle_victim(victim)


func get_potential_victims() -> Array:
	var areas: Array = hit_box.get_overlapping_areas()

	var victims := []
	for area in areas:
		if area.has_method("get_unit"): # if it's a hurtbox
			victims.append(area.get_unit())

	return victims


## if there is an attached HitApprover node, ask it if we can actually hit
## this victim. otherwise, assume yes
func get_approval(victim: Unit) -> bool:
	#print("get_approval() called")
	if hit_approver:
		return hit_approver.approve_hit(victim)
	else:
		return true


## If the victim can take buffs and does not have the DamageCooldown buff for
## the sawblade, deal damage and apply the buff.
func handle_victim(victim: Unit):
	#if victim.has_method("get_buffs"):
	var buffs: Array = victim.get_buffs()
	for buff in buffs:
		if buff.get("source") == self:
			return

	# if we got here, we can deal damage
	var dc: DamageCooldown = damage_cooldown_scene.instance()
	dc.setup(self, damage_cooldown)
	victim.add_buff(dc)
	victim.take_damage(damage, source)
	emit_signal("dealt_damage", victim, damage)


