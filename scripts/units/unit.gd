extends KinematicBody2D
class_name Unit
## Base class for characters like Players and Enemies.
## This script should act as interface between its child nodes and the outside world.
## (and between different child nodes?)


## will be set on ready if one is present?
## can be changed by extending classes
var mover

## not sure if this is the best way to do this
## will be built based on children of the CombatResources node
var combat_resources: Dictionary

## this one is just onready because I don't think it will have to be extended?
## might have to change later
onready var movement_stats: MovementStats = $MovementStats

onready var buffs_node: Node2D = $Buffs


# ----------
# setup funcs
# ----------


# calls setup_mover() and setup_combat_resources()
func _ready() -> void:
	# potential problems if there are multiple movers?
	for c in get_children():
		if c is Mover:
			mover = c
			break

	combat_resources = setup_combat_resources()


## returns a dictionary mapping combat resource type -> combat resource node
func setup_combat_resources() -> Dictionary:
	var crs := {}
	for rsrc in $CombatResources.get_children():
		if rsrc is CombatResource:
			crs[rsrc.type] = rsrc
	return crs


# --
# ----------
# other funcs
# ----------
# --


## calls mover's physics update
func _physics_process(delta: float) -> void:
	mover.physics_update(self, movement_stats, delta)


# ----------
# resource-related funcs
# ----------


func has_combat_resource(type: int) -> bool:
	return type in combat_resources


## returns false if this unit does not have the given type of resource
func can_spend_resource(type: int, amount: int) -> bool:
	if amount == 0:
		return true
	return has_combat_resource(type) and combat_resources[type].value >= amount


## returns true/false based on if the amount was actually spent
## NOTE: distinct from losing
func spend_resource(type: int, amount: int) -> bool:
	if amount == 0:
		return true
	return can_spend_resource(type, amount) and combat_resources[type].change_value(amount * -1)


## returns true/false based on if the amount was actually lost
## NOTE: distinct from spending
func lose_resource(type: int, amount: int) -> bool:
	if amount == 0:
		return true
	return has_combat_resource(type) and combat_resources[type].change_value(amount * -1)


## returns false if doesnt have that resource or if already at max
func can_gain_resource(type: int, _amount: int) -> bool:
	return has_combat_resource(type) and (combat_resources[type].value < combat_resources[type].MAX_VALUE)


## returns true/false based on if the amount was actually gained
func gain_resource(type: int, amount: int) -> bool:
	return can_gain_resource(type, amount) and combat_resources[type].change_amount(amount)


## should be connected to hitbox signals
## just calls lose_resource method
func take_damage(amount: int, _source):
	# warning-ignore:return_value_discarded
	lose_resource(CombatResource.Type.HEALTH, amount)


## should be connected to the signal of the health resource
## if the new amount is 0, we ded
func _check_for_death(new_health_value) -> void:
	if new_health_value == 0:
		queue_free() # NOTE: should have a seperate die() method?


# ----------
# buff-related funcs
# ----------


## NOTE: I'm trying a style that doesn't specify the class of params/objects as
## much.
## The buff param just has to be a Node of some kind.
func add_buff(buff):
	buffs_node.add_child(buff)


## If the given buff is present on this unit, it will be removed and freed.
## Returns true/false if the buff was actually found and removed
func remove_buff(buff):
	var buffs_arr: Array = get_buffs()

	for b in buffs_arr:
		if b == buff:
			buffs_node.remove_child(b)
			return true

	return false


## Returns a list of all the buffs on this unit.
func get_buffs() -> Array:
	return buffs_node.get_children()

