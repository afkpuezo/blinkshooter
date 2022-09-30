extends Node
class_name EnemyWeaponBar
## very placeholder
## managers enemy attacks, when the player is detected, find all of the attacks which are off
## cooldown, picks one at random and triggers it


# DONT type hint as enemy, cyclical
onready var user = get_parent()
var actions := []
var rng = RandomNumberGenerator.new()


func _ready() -> void:
	rng.randomize()
	for c in get_children():
		if c is Action:
			actions.append(c)
			c.configure_user(user) # this method is probably bad


## triggers a random (ready) action from the currently equipped actions
## returns true/false depending if that actually happened
func trigger_random_action() -> bool:
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
		action.trigger()
		return true



