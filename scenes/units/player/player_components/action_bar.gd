extends Node2D
class_name ActionBar
## Acts as an interface between the player node and the actions they can perform
## NOTE: this is currently a placeholder
## NOTE: needs a way to add/remove actions?


onready var user := get_parent() # gross
var actions := [] # seems better than constatly calling get_child

export var num_slots := 3 # There's probably a better way to set this up
var action_slot_events := {}


func _ready() -> void:
	# set up action slots
	var slot_template := "action_slot_%d"
	for n in range(0, num_slots):
		actions.append(null)
		action_slot_events[slot_template % (n + 1)] = n
	# set up actions
	for action in get_children():
		add_action(action, true)


func add_action(new_action, is_already_child = false):
	var first_empty_slot := -1

	# do we already have this kind of action?
	for x in range(num_slots):
		var existing_action = actions[x]
		if existing_action == null:
			if first_empty_slot == -1:
				first_empty_slot = x
		elif existing_action.name == new_action.name:
			print("DEBUG: action already owned")
			return # maybe handle this differently?

	var added := false

	# can it go in its default slot?
	if new_action.has_method("get_default_slot"):
		var default_slot = new_action.get_default_slot()
		if 0 <= default_slot and default_slot < num_slots and actions[default_slot] == null:
			actions[default_slot] = new_action
			added = true
			print("DEBUG: action added to default slot")

	# if it couldn't go in the default slot, put it in the first empty slot
	if not added:
		if first_empty_slot != -1:
			actions[first_empty_slot] = new_action
			added = true
			print("DEBUG: action added to first open slot")
		else:
			print("DEBUG: no room for action")
			return

	# setup
	if not is_already_child:
		add_child(new_action)
	if new_action.has_method("configure_user"):
		new_action.configure_user(user)


## Triggers the equipped action corresponding to the button pressed
func _unhandled_input(event: InputEvent) -> void:
	for ase in action_slot_events:
		if event.is_action_pressed(ase):
			var slot = action_slot_events[ase]
			if slot < len(actions) and Action.is_action(actions[slot]):
				actions[slot].trigger()
