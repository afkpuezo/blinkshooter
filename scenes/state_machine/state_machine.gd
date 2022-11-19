extends Node
class_name StateMachine
## generic state machine based on:
## https://www.gdquest.com/tutorial/godot/design-patterns/finite-state-machine/
## Initializes states and delegates engine callbacks (eg _physics_process, _unhandled_input) to the
## active state.


## Emitted when transitioning to a new state.
signal transitioned(state_name)

export var initial_state := NodePath()
onready var current_state: State = get_node(initial_state)


func _ready() -> void:
	yield(owner, "ready")
	# The state machine assigns itself to the State objects' state_machine property.
	for child in get_children():
		child.connect("state_change_triggered", self, "transition_to")
	current_state.enter()


# The state machine subscribes to node callbacks and delegates them to the state objects.
func _unhandled_input(event: InputEvent) -> void:
	current_state.handle_input(event)


func _process(delta: float) -> void:
	current_state.update(delta)


func _physics_process(delta: float) -> void:
	current_state.physics_update(delta)


# This function calls the current state's exit() function, then changes the active state,
# and calls its enter function.
# It optionally takes a `msg` dictionary to pass to the next state's enter() function.
func transition_to(target_state_name: String, msg: Dictionary = {}) -> void:
	# Safety check, you could use an assert() here to report an error if the state name is incorrect.
	# We don't use an assert here to help with code reuse. If you reuse a state in different state machines
	# but you don't want them all, they won't be able to transition to states that aren't in the scene tree.
	if not has_node(target_state_name):
		return

	current_state.exit()
	current_state = get_node(target_state_name)
	current_state.enter(msg)
	emit_signal("transitioned", current_state.name)
