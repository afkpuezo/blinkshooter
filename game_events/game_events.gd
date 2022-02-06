extends Node
# no class_name because autoload takes care of that
## Event bus/manager for aid in decoupling
## Node A subscribes to this, Node B triggers this, this signals to Node A
## based on https://www.gdquest.com/docs/guidelines/best-practices/godot-gdscript/event-bus/
## events should have a single msg parameter, which is a dict of needed parameters


# dummy event for demo purposes
signal test_event(msg)


# used for changes to player combat stats
signal player_combat_stat_value_changed(msg)
signal player_died(msg)
