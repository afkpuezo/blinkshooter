extends Node
# no class_name because autoload takes care of that
## Event bus/manager for aid in decoupling
## Node A subscribes to this, Node B triggers this, this signals to Node A
## based on https://www.gdquest.com/docs/guidelines/best-practices/godot-gdscript/event-bus/
## events should have a single msg parameter, which is a dict of needed parameters


# dummy event for demo purposes
signal test_event(msg)


# ----------
# Player related
# ----------


# used for changes to player combat stats
# msg fields: "type", "value", "change", "max"
signal player_combat_resource_value_changed(msg)


# RIP
signal player_died(msg)


# ----------
# Spawner related
# ----------


# msg fields: "object"
signal game_object_spawned(msg)
