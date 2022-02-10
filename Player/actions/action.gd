extends Node
class_name Action
## This is an 'abstract' class that represents a single player (or enemy?) action/ability/spell
## It should be attached to an ActionBar node


# TODO these are placeholder
signal action_started(msg)
signal action_ended(msg)


export var cost:= {
	CombatResource.CombatResourceType.HEALTH: 0.0,
	CombatResource.CombatResourceType.ENERGY: 0.0,
}
