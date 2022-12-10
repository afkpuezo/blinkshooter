extends Node
class_name MovementStats
## Intended as a simple container for movement related stats for a game object
## (eg max speed, acceleration, etc).
## This way, if an object has multiple ways of being moved, there will be one
## clear source of values
## TODO: should this have been some kind of simple object rather than a node?


export var acceleration := 500.0
export var max_speed := 100.0
export(int, 0, 100) var friction_percent = 10 # only applied when no movement input
var velocity := Vector2.ZERO


# ----------
# static/util funcs
# ----------

## Returns true/false depending on if the given node has a movement stats child node
static func has_movement_stats(n: Node) -> bool:
	return get_movement_stats(n) != null


## Returns null if no such child found.
## First checks to see if there is a child called MovementStats, then checks all of the chidlren
## for a node of that class.
## TODO: maybe make the name required?
static func get_movement_stats(n: Node) -> MovementStats:
	if n.has_node(get_movement_stats_class()):
		var mvs: MovementStats = n.get_node(get_movement_stats_class())
		return mvs
	for child in n.get_children():
		#print("DEBUG: child.get_class(): %s" % child.get_class())
		if child.get_class() == get_movement_stats_class():
			return child
	return null


## wish I could just have static vars
static func get_movement_stats_class() -> String:
	return "MovementStats"


## Has to be overriden or this will just return "Node"
func get_class() -> String:
	return get_movement_stats_class()


# ----------
# instance funcs
# ----------


## I probably won't incorporate mass or anything, but in case I do it will be
## incorporated here
func apply_outside_force(force: Vector2):
	velocity += force
