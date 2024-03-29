extends Node
class_name State
## used by state machines
## this is an 'abstract' class to be extended by specific use cases
## based on https://www.gdquest.com/tutorial/godot/design-patterns/finite-state-machine/


## Called by this node to tell
# warning-ignore:unused_signal
signal state_change_triggered(target_state, msg)


# Virtual function. Receives events from the `_unhandled_input()` callback.
func handle_input(_event: InputEvent) -> void:
	pass


# Virtual function. Corresponds to the `_process()` callback.
func update(_delta: float) -> void:
	pass


# Virtual function. Corresponds to the `_physics_process()` callback.
func physics_update(_delta: float) -> void:
	pass


# Virtual function. Called by the state machine upon changing the active state. The `msg` parameter
# is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_msg := {}) -> void:
	pass


# Virtual function. Called by the state machine before changing the active state. Use this function
# to clean up the state.
func exit() -> void:
	pass
