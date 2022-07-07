extends Node
class_name Action
## This is an 'abstract' class that represents a single user (or enemy?) action/ability/spell
## It should be attached to an ActionBar node
## Specific action subclasses should mostly only need to overwrite the do_effect() method


# TODO these are placeholder
signal action_started(msg)
signal cooldown_finished(msg) # when action is ready again


# it's a little gross to manually put each type of resource?
export var health_cost := 0
export var energy_cost := 0
export var basic_ammo_cost := 0
export var big_ammo_cost := 0
onready var cost:= {
	CombatResource.Type.HEALTH: health_cost,
	CombatResource.Type.ENERGY: energy_cost,
	CombatResource.Type.BASIC_AMMO: basic_ammo_cost,
	CombatResource.Type.BIG_AMMO: big_ammo_cost,
}

export(float, 0.0, 60.0) var cooldown = 0.1
var _cooldown_timer: Timer
var is_cooling_down := false

onready var user: Player # set by ActionBar
var user_combat_resources: Dictionary


func _ready() -> void:
	# prepare cooldown timer
	_cooldown_timer = Timer.new()
	_cooldown_timer.autostart = false
	_cooldown_timer.one_shot = true
	add_child(_cooldown_timer)


# ----------
# replace this method(s) for each specific action
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
	#print("DEBUG: Action.do_action() empty method called")
	pass


# ----------
# public methods
# ----------


## Called by the ActionBar when the Action node is attached / when the Action is unlocked
func configure_user(new_user) -> void:
	user = new_user
	# NOTE: assumes particular scene architecture
	user_combat_resources = {} # reset if changing users I guess?
	for rsrc in user.get_node("CombatResources").get_children():
		user_combat_resources[rsrc.type] = rsrc


## Called by the ActionBar when the user TRIES to use this ability.
## Returns true if the action is executed, false otherwise (eg cooldown or no resources)
func trigger() -> bool:
	#print("DEBUG: trigger called")
	if is_cooldown_ready() and can_user_pay() and can_do_action():
		emit_signal("action_started") # TODO send args?
		_start_cooldown()
		_pay_cost()
		do_action()
		# TODO: rethink the action_ended signal
		return true
	else:
		return false


## Returns true if the cooldown timer is not currently running
func is_cooldown_ready() -> bool:
	return _cooldown_timer.time_left == 0 # NOTE: should this be .stopped()?


## Returns true if the user has the resources to pay for this action
func can_user_pay() -> bool:
	for type in cost:
		if not type in user_combat_resources or user_combat_resources[type].value < cost[type]:
			return false
	return true


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
		user_combat_resources[type].change_value(cost[type] * -1)