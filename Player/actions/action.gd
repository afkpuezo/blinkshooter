extends Node
class_name Action
## This is an 'abstract' class that represents a single player (or enemy?) action/ability/spell
## It should be attached to an ActionBar node
## Specific action subclasses should mostly only need to overwrite the do_effect() method


# TODO these are placeholder
signal action_started(msg)
signal action_ended(msg)
signal cooldown_finished(msg) # when action is ready again


# it's a little gross to manually put each type of resource?
export var health_cost := 0
export var energy_cost := 0
var cost:= {
	CombatResource.Type.HEALTH: health_cost,
	CombatResource.Type.ENERGY: energy_cost,
}

export(float, 0.0, 60.0) var cooldown = 0.1
var _cooldown_timer: Timer
var is_cooling_down := false

onready var player = owner.owner # TODO: make this less sketchy
var player_combat_resources: Dictionary


func _ready() -> void:
	# prepare cooldown timer
	_cooldown_timer = Timer.new()
	_cooldown_timer.autostart = false
	_cooldown_timer.one_shot = true
	add_child(_cooldown_timer)
	# get the player combat resources
	# NOTE: assumes certain scene architecture
	for rsrc in player.get_node("CombatResources").get_children():
		if rsrc is CombatResource:
			print("DEBUG: CombatResource found: " + rsrc.name)


# ----------
# replace this method(s) for each specific action
# ----------


## Executes the actual effects of the action. You don't need to handle cooldown or costs here
func do_action() -> void:
	pass


# ----------
# public methods
# ----------


## Called by the ActionBar when the player uses this ability.
func trigger() -> void:
	pass
