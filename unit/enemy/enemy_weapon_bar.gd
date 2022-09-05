extends Node
class_name EnemyWeaponBar
## very placeholder
## managers enemy attacks, when the player is detected, find all of the attacks which are off
## cooldown, picks one at random and triggers it


onready var user: Enemy = get_parent()
var actions := []
var rng = RandomNumberGenerator.new()


func _ready() -> void:
	rng.randomize()
	for c in get_children():
		if c is Action:
			actions.append(c)
			c.configure_user(user) # this method is probably bad


func _process(delta: float) -> void:
	if user.is_player_detected():
		var action = pick_action()
		if action:
			action.trigger()


func pick_action() -> Action:
	print("DEBUG: pick_action() called")
	var ready_actions := []
	for a in actions:
		if a.is_ready():
			ready_actions.append(a)
			print("DEBUG: pick_action() found ready action: %s" % a.name)

	return ready_actions[rng.randi_range(0, ready_actions.size() - 1)] if ready_actions else null



