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

## msg fields: "player"
# warning-ignore:unused_signal
signal player_spawned(msg)

## used for changes to player combat stats
## msg fields: "type", "value", "change", "max"
# warning-ignore:unused_signal
signal player_combat_resource_value_changed(msg)

# RIP
# warning-ignore:unused_signal
signal player_died(msg)

## used when the player changes weapon slots
## msg fields: "old_weapon_slot", "new_weapon_slot"
# warning-ignore:unused_signal
signal player_changed_weapon(msg)

## action/weapon bars emit these periodically.
## msg fields: "actions" -> list of currently equipped actions/weapons where
##		index is their slot number
## each action has a sub-dict with these fields:
##		"name", "cooldown_remaining", "can_be_triggered", "triggered_this_frame"
## empty slots will have the name "empty"
# warning-ignore:unused_signal
signal player_action_bar_tick(msg)
# warning-ignore:unused_signal
signal player_weapon_bar_tick(msg)

## called when the teleportation starts
# (used to trigger animation in new player scene)
# might come back to add args to this
# warning-ignore:unused_signal
signal player_teleport_started()

## called when the player actually moves
# might come back to add args to this
# warning-ignore:unused_signal
signal player_teleported()

# ----------
# Spawner related
# ----------

# msg fields: "object"
# warning-ignore:unused_signal
signal game_object_spawned(msg)

# ----------
# Enemy related
# ----------

## msg fields: "enemy", "is_boss"
## called by enemies (brains) when they spawn
# warning-ignore:unused_signal
signal enemy_spawned(msg)

## msg fields: "global_position"
## called by enemies when they die
# (can't refer to the enemy itself because it will be freed, I think)
# might want to include enemy type or something later
# warning-ignore:unused_signal
signal enemy_died(msg)

