extends Node2D
class_name PlayerBrain
## This once was the Player class, but I decided to revise the structure for Units
## This component contains some extra functionality to turn a Unit into the Player
## TODO get a better name for this class


onready var anim_player: AnimationPlayer = $AnimationPlayer
onready var player_mover: PlayerMover = $PlayerMover
onready var player_movement_stats: MovementStats = MovementStats.get_movement_stats(owner)


# ----------
# static funcs
# ----------


## Checks if the given node is a unit and has a PlayerBrain component
static func is_player(n: Node) -> bool:
	if n != null and n is Unit:
		for c in n.get_children():
			if c.has_method("is_player"):
				return true
	return false


## Currently used by enemies to figure out who an attack came from.
## I kludged it so that bullets have the player as a source but the attacks
## from actions (such as the shuriken) point to the action node.
## This method will handle both cases.
## Returns the player (unit) node if it is the source of this attack, otherwise
## null
static func get_player_if_source(n: Node):
	if n == null:
		return null
	elif is_player(n):
		return n
	elif n.has_method("get_user") and is_player(n.get_user()):
		return n.get_user()
	else:
		return null


## used by the LevelLoader, returns a dictionary of the information needed to
## restore the player after loading a checkpoint or moving to a new level zone
## currently just tracks value of combat resources
static func save_player_state(p: Unit) -> Dictionary:
	assert (is_player(p))
	var crs := CombatResource.get_combat_resources(p)
	var data := {}

	for cr in crs:
		var sub := {
			'min': cr.MIN_VALUE,
			'max': cr.MAX_VALUE,
			'value': cr.value
		}
		data[cr.type] = sub

	print("save_player_state() about to return data: %s" % data)
	return data


## used by the LevelLoader, restores the state of the player
static func load_player_state(p: Unit, data: Dictionary):
	print("load_player_state() called, data: %s" % data)
	assert (is_player(p))
	var crs := CombatResource.get_combat_resources(p)

	for cr in crs:
		if cr.type in data:
			var sub: Dictionary = data[cr.type]
			cr.set_values(cr['min'], cr['max'], cr['value'])
		else:
			print("PlayeBrain.load_player_state(): type key not in data: %s" % cr.type)


# ----------
# ready and setup methods
# ----------


func _ready() -> void:
	GameEvents.emit_signal("player_spawned", {'player': owner})
	# warning-ignore:return_value_discarded
	GameEvents.connect("player_teleport_started", self, "do_teleport_animation")


# ----------
# instance-level methods
# ----------


## from Unit signal
func on_unit_death():
	GameEvents.emit_signal("player_died", {'player': owner})


## call the animation on the animation player
## TODO connect to event
func do_teleport_animation():
	anim_player.play("Teleport")


## reset animation
func _on_animation_end(_old_anim):
	anim_player.play("Idle")


## takes care of moving the player unit
func _physics_process(_delta: float) -> void:
	player_mover.physics_update(owner, player_movement_stats)
