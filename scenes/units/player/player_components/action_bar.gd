extends Node2D
class_name ActionBar
## Acts as an interface between the player node and the actions they can perform


onready var user := get_parent() # gross
var actions := [] # seems better than constatly calling get_child

export var num_slots := 3 # There's probably a better way to set this up
var monitored_events := {}

# arr of bools, matching index of actions.
# might make sense to do a dict or something else instead?
var actions_triggered_this_frame := []


# ----------
# setup
# ----------


func _ready() -> void:
	setup_events()
	# set up action slots
	for _n in range(0, num_slots):
		actions.append(null)
		actions_triggered_this_frame.append(false)
	# set up actions
	for action in get_children():
		add_action(action, true)


func setup_events():
	var slot_template := "action_slot_%d"
	for n in range(0, num_slots):
		monitored_events[slot_template % (n + 1)] = n


# ----------
# common with ActionBar and WeaponBar
# ----------


func _process(_delta: float) -> void:
	during_process()
	emit_update_tick()


## Triggers the equipped action corresponding to the button pressed
func _unhandled_input(event: InputEvent) -> void:
	handle_event(event)


func add_action(new_action, is_already_child = false):
	var first_empty_slot := -1

	# do we already have this kind of action?
	for x in range(num_slots):
		var existing_action = actions[x]
		if existing_action == null:
			if first_empty_slot == -1:
				first_empty_slot = x
		elif existing_action.name == new_action.name:
			print("%s finds action already owned: %s" % [name, existing_action.name])
			return # maybe handle this differently?

	var added := false

	# can it go in its default slot?
	if new_action.has_method("get_default_slot"):
		var default_slot = new_action.get_default_slot()
		if 0 <= default_slot and default_slot < num_slots and actions[default_slot] == null:
			actions[default_slot] = new_action
			added = true

	# if it couldn't go in the default slot, put it in the first empty slot
	if not added:
		if first_empty_slot != -1:
			actions[first_empty_slot] = new_action
			added = true
		else:
			return

	# setup
	if not is_already_child:
		call_deferred("add_child", new_action)
		#add_child(new_action)
	#if new_action.has_method("configure_user"):
	#	new_action.configure_user(user)
	new_action.user = user
# end add_action()


## called by handle_event or other sources
## TODO look at actions_triggered_this_frame
func trigger_action(slot: int):
	#if actions[slot].trigger():
	#	actions_triggered_this_frame[slot] = true
	actions[slot].trigger()
	actions_triggered_this_frame[slot] = true


## called periodically to emit a GameEvent signal describing the status of the
## currently equipped
func emit_update_tick():
	var actions_arr := []

	for action_index in range(num_slots):
		var sub := emit_update_tick_help(action_index)

		actions_arr.append(sub)
	# end for x
	var msg = {
		'actions': actions_arr
	}

	GameEvents.emit_signal(
		get_event_signal_string(),
		msg
	)

	# resetting it here makes it easier to move out of process if I want to
	# change the frequency
	# reset actions_triggered_this_frame
	for x in range(num_slots):
		actions_triggered_this_frame[x] = false

# end emit_update_tick()


# ----------
# should be overridden by WeaponBar
# ----------


## making this a function makes it override-able i guess?
static func get_event_signal_string() -> String:
	return "player_action_bar_tick"


## Putting this in a helper method lets WeaponBar override the logic. For some
## reason WeaponBar was having trouble extending _unhandled_input() directly
func handle_event(event: InputEvent):
	for ase in monitored_events:
		if event.is_action_pressed(ase):
			var slot = monitored_events[ase]
			if slot < len(actions) and Action.is_action(actions[slot]):
				trigger_action(slot)


## because logic handling actions_triggered_this_frame and emit_update_tick()
## takes place in the _process() method, it's hard to extend that in WeaponBar
## This method lets WeaponBar deal with firing without interfering with the
## signalling logic
func during_process():
	pass


## helper method for the emit_update_tick() method, creates the sub-dictionary
## representing a single action in the final signal
## (making this a helper lets WeaponBar override it to include the current slot)
func emit_update_tick_help(action_index: int) -> Dictionary:
	var action: Action = actions[action_index]
	var sub := {}
	if action == null:
		sub['name'] = "empty"
		sub['cooldown_remaining'] = 0.0
		sub['is_ready'] = false
		sub['was_triggered_this_frame'] = false
		#sub['index'] = action_index
	else:
		sub['name'] = action.name
		sub['cooldown_remaining'] = action.get_remaining_cooldown()
		sub['is_ready'] = action.is_ready(true) # ignore cooldown for this
		sub['was_triggered_this_frame'] = actions_triggered_this_frame[action_index]
		#sub['index'] = action_index
	return sub
