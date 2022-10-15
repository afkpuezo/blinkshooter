extends Node
class_name CombatResource
## Represents a single Resource/bar for a character, eg health or energy

signal value_changed(new_value)

# NOTE: update get_all_types() when creating a new type!
enum Type {HEALTH, ENERGY, BASIC_AMMO, BIG_AMMO}

export var MAX_VALUE := 100
export var MIN_VALUE := 0 # needed?
export var REGEN := 0
export var INITIAL_VALUE: int = 999999 # note - will get clmaped
export(float, 0.1, 3.0) var REGEN_PERIOD = 0.1
export(Type) var type = Type.HEALTH
export var is_player := false ## If set to true, will trigger relevant events

onready var value = clamp(INITIAL_VALUE, MIN_VALUE, MAX_VALUE)


# ----------
# static and/or util methods
# ----------


## Returns true if the given combat resource is some kind of ammo, false otherwise.
## Takes either a CombatResource node, or a Type enum.
## NOTE: this is static/class level rather than instance because events related to combat resources
## will not provide a reference to the actual CombatResource node.
static func is_ammo(rsrc) -> bool:
	if typeof(rsrc) != TYPE_INT:
		rsrc = rsrc.type
	return rsrc in [Type.BASIC_AMMO, Type.BIG_AMMO] # potentially slow lookup?


## Returns true if the given node has a "CombatResources" child node to group any actual combat
## resources it has.
## TODO: rethink these "CombatResources" nodes
static func has_combat_resources(n: Node) -> bool:
	return n.has_node("CombatResources")


## Returns an array of all of the combat resource nodes of the given node
## NOTE: will this have side effects if the returned array is changed?
## Will break if the node doesn't have a CombatResources child group node
static func get_combat_resources(n: Node) -> Array:
	return n.get_node("CombatResources").get_children()


## Returns true if the given node has the specific type of resource given.
## TODO: version with string names?
static func has_resource(n: Node, q_type: int) -> bool:
	var has_group := has_combat_resources(n)
	if not has_group:
		return false
	var resources := get_combat_resources(n)
	for rsrc in resources:
		if rsrc.type == q_type:
			return true
	return false


## Returns the CombatResource node for the given node of the given type
## returns null if no such resource found
static func get_resource(n: Node, q_type: int) -> CombatResource:
	var resources = get_combat_resources(n)
	for rsrc in resources:
		if rsrc.type == q_type:
			return rsrc
	return null

## wish I could just have static vars
static func get_combat_resource_class() -> String:
	return "CombatResource"


func get_class() -> String:
	return get_combat_resource_class()


## NOTE: needs to be manually updated when new types are added!!!
static func get_all_types() -> Array:
	return [Type.HEALTH, Type.ENERGY, Type.BASIC_AMMO, Type.BIG_AMMO]


# ----------
# ready/constructor methods
# ----------


## report max value for set up, create regen timer
func _ready() -> void:
	_report_value_change(0)
	var timer := Timer.new()
	# warning-ignore:return_value_discarded
	timer.connect("timeout", self, "_apply_regen")
	add_child(timer)
	timer.start(REGEN_PERIOD)


# ----------
# public methods
# ----------


## can take a positive or negative value, ignores 0
## if there would be no change (eg healing when at max), does nothing
## returns true if the value was changed, false otherwise
func change_value(amount: int) -> bool:
	var was_changed := false
	if amount > 0:
		was_changed = _increase_value(amount)
	elif amount < 0:
		was_changed = _decrease_value(amount)
	if was_changed:
		_report_value_change(amount)
	return was_changed


# ----------
# private methods
# ----------


## triggered by timer
func _apply_regen():
	# warning-ignore:return_value_discarded
	change_value(REGEN)


## if the value is not already maxed increase current value by the given amount
## and return true.
## if the value is already maxed, return false.
func _increase_value(amount: int) -> bool:
	if value == MAX_VALUE:
		return false
	else:
		value = min(MAX_VALUE, value + amount)
		return true


## if the value is not already at the minimum, decrease current value by the
## given amount and return true.
## if the value is already at the minimum, return false.
func _decrease_value(amount: int) -> bool:
	if value == MIN_VALUE:
		return false
	else:
		value = max(MIN_VALUE, value + amount)
		return true


## change is the amount that the value changed
func _report_value_change(change: int):
	emit_signal("value_changed", value)
	if is_player:
		GameEvents.emit_signal(
				"player_combat_resource_value_changed",
				{
					"type": type,
					"value": value,
					"change": change,
					"max": MAX_VALUE,
				})
