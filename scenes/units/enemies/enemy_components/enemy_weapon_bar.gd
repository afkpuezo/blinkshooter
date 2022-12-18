extends Node2D
class_name EnemyWeaponBar
## very placeholder
## managers enemy attacks, when the player is detected, find all of the attacks which are off
## cooldown, picks one at random and triggers it


# DONT type hint as enemy, cyclical
onready var user = owner # TODO better way?
var actions := []
var rng = RandomNumberGenerator.new()


## TODO rework this
func _ready() -> void:
	rng.randomize()
	for c in get_children():
		if c is Action:
			add_action(c, true)


## takes care of childing and configuring it
func add_action(action, is_already_child = false):
	if not is_already_child:
		add_child(action)
	actions.append(action)
	action.configure_user(user)


## triggers a random (ready) action from the currently equipped actions
## returns true/false depending if that actually happened
func trigger_random_action(target = null) -> bool:
	#print("DEBUG: pick_action() called")
	var ready_actions := []
	for a in actions:
		if a.is_ready():
			ready_actions.append(a)
			#print("DEBUG: pick_action() found ready action: %s" % a.name)

	if not ready_actions:
		return false
	else:
		var action: Action = ready_actions[rng.randi_range(0, ready_actions.size() - 1)]
		# warning-ignore:return_value_discarded
		action.trigger(target)
		return true



