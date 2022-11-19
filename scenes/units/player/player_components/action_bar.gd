extends Node2D
class_name ActionBar
## Acts as an interface between the player node and the actions they can perform
## NOTE: this is currently a placeholder
## NOTE: needs a way to add/remove actions?


onready var user := get_parent() # gross
var actions: Array # seems better than constatly calling get_child

export var num_slots := 3 # There's probably a better way to set this up
var action_slot_events := {}


func _ready() -> void:
	# set up action slots
	var slot_template := "action_slot_%d"
	for n in range(0, num_slots):
		action_slot_events[slot_template % (n + 1)] = n
	# set up actions
	for action in get_children():
		add_action(action, true)


func add_action(action, is_already_child = false):
	if action.has_method("configure_user"):
		if not is_already_child:
			add_child(action)
		action.configure_user(user)
		actions.append(action)


## Triggers the equipped action corresponding to the button pressed
func _unhandled_input(event: InputEvent) -> void:
	for ase in action_slot_events:
		if event.is_action_pressed(ase):
			var slot = action_slot_events[ase]
			if slot < len(actions) and Action.is_action(actions[slot]):
				actions[slot].trigger()
