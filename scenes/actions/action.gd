extends Node2D
class_name Action
## This is an 'abstract' class that represents a single user (or enemy?) action/ability/spell
## It should be attached to an ActionBar node
## Specific action subclasses should mostly only need to overwrite the do_effect() method


# arg is 'action': self, 'user': user
signal action_started(msg)
# warning-ignore:unused_signal
signal cooldown_finished(msg) # when action is ready again


# it's a little gross to manually put each type of resource?
export var health_cost := 0
export var energy_cost := 0
export var basic_ammo_cost := 0
export var PLASMA_AMMO_cost := 0
onready var cost:= {
	CombatResource.Type.HEALTH: health_cost,
	CombatResource.Type.ENERGY: energy_cost,
	CombatResource.Type.BASIC_AMMO: basic_ammo_cost,
	CombatResource.Type.PLASMA_AMMO: PLASMA_AMMO_cost,
}

export(float, 0.0, 60.0) var cooldown = 0.1
var _cooldown_timer: Timer
var is_cooling_down := false

## used by the player when picking up this Action
export var default_slot := -1 setget ,get_default_slot
func get_default_slot() -> int: return default_slot

# did I give this a setget for get_method()?
var user: Unit setget configure_user # set from the outside
var target: Unit # rarely used


# ----------
# static functions
# ----------


## probably overkill
static func is_action(n: Node) -> bool:
	return n != null and n.has_method("trigger")


# ----------
# _ready()
# ----------


## shouldn't have to be overrided for most specific actions
func _ready() -> void:
	# prepare cooldown timer
	_cooldown_timer = Timer.new()
	_cooldown_timer.autostart = false
	_cooldown_timer.one_shot = true
	add_child(_cooldown_timer)


# ----------
# replace these method(s) for each specific action
# ----------


## Returns true if the action could be executed right now.
## This is for conditions that are specific to the particular action (eg target in range), and not
## generic conditions like cooldown and resource cost.
## Defaults to true
## TODO: reconsider the name
func can_do_action() -> bool:
	return true


## Executes the actual effects of the action. You don't need to handle cooldown or costs here
func do_action() -> void:
	pass


# ----------
# public methods
# ----------


## Called by the ActionBar when the Action node is attached / when the Action is unlocked
## have to clear ref when the user dies
func configure_user(new_user) -> void:
	user = new_user
	# warning-ignore:return_value_discarded
	user.connect("died", self, "on_user_death")


## clears ref to avoid crash
func on_user_death():
	user = null


## Called by the ActionBar when the user TRIES to use this ability.
## Returns true if the action is executed, false otherwise (eg cooldown or no resources)
func trigger(new_target: Unit = null) -> bool:
	if new_target:
		target = new_target

	if is_ready():
		emit_action_started_signal()
		_start_cooldown()
		_pay_cost()
		do_action()
		# TODO: rethink the action_ended signal
		return true
	else:
		return false


func emit_action_started_signal():
	emit_signal(
		"action_started",
		{
			'action': self,
			'user': user,
		}
	)


## Returns true if the cooldown timer is not currently running
func is_cooldown_ready() -> bool:
	return get_remaining_cooldown() == 0 # NOTE: should this be .stopped()?


func get_remaining_cooldown() -> float:
	return _cooldown_timer.time_left


## Returns true if the user has the resources to pay for this action
func can_user_pay() -> bool:
	if not user:
		return false

	for type in cost:
		if not user.can_spend_resource(type, cost[type]):
			return false
	return true


## returns true if ALL conditions for using the action are true
## the ignore_cooldown param is used for ui stuff
func is_ready(ignore_cooldown = false) -> bool:
	return (is_cooldown_ready() or ignore_cooldown) and can_user_pay() and can_do_action()


# ----------
# private methods
# ----------


## Probably overkill right now
func _start_cooldown():
	_cooldown_timer.start(cooldown)


## Informs the combat resources that they have been spent
## Assumes the player has enough
func _pay_cost():
	for type in cost:
		#user_combat_resources[type].change_value(cost[type] * -1)
		# warning-ignore:return_value_discarded
		user.spend_resource(type, cost[type])
