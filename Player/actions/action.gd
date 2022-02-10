extends Node
class_name Action
## This is an 'abstract' class that represents a single player (or enemy?) action/ability/spell
## It should be attached to an ActionBar node


# TODO these are placeholder
signal action_started(msg)
signal action_ended(msg)


# it's a little gross to manually put each type of resource?
export var health_cost := 0
export var energy_cost := 0

var cost:= {
	CombatResource.Type.HEALTH: health_cost,
	CombatResource.Type.ENERGY: energy_cost,
}
