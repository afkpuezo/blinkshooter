extends Node
# no class_name because autoload takes care of that
## Event bus/manager for aid in decoupling
## Node A subscribes to this, Node B triggers this, this signals to Node A
## based on https://www.gdquest.com/docs/guidelines/best-practices/godot-gdscript/event-bus/
## events should have a single msg parameter, which is a dict of needed parameters


# dummy event for demo purposes
# warning-ignore:unused_signal
signal test_event(msg)


# ----------
# Player related
# ----------


## used for changes to player combat stats
## msg fields: "type", "value", "change", "max"
# warning-ignore:unused_signal
signal player_combat_resource_value_changed(msg)


## used when the player changes weapon slots
## msg fields: "old_weapon_slot", "new_weapon_slot"
# warning-ignore:unused_signal
signal player_changed_weapon(msg)


# RIP
# warning-ignore:unused_signal
signal player_died(msg)


# ----------
# Spawner related
# ----------


# msg fields: "object"
# warning-ignore:unused_signal
signal game_object_spawned(msg)
