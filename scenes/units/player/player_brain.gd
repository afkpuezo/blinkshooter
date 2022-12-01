extends Node2D
class_name PlayerBrain
## This once was the Player class, but I decided to revise the structure for Units
## This component contains some extra functionality to turn a Unit into the Player
## TODO get a better name for this class


onready var anim_player: AnimationPlayer = $AnimationPlayer


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
	if is_player(n):
		return n
	elif n.has_method("get_user") and is_player(n.get_user()):
		return n.get_user()
	else:
		return false


# ----------
# ready and setup methods
# ----------


func _ready() -> void:
	GameEvents.emit_signal("player_spawned", {'player': self})
	GameEvents.connect("player_teleport_started", self, "do_teleport_animation")


# ----------
# instance-level methods
# ----------


## from Unit signal
func on_unit_death():
	GameEvents.emit_signal("player_died", {'player': self})


## call the animation on the animation player
## TODO connect to event
func do_teleport_animation():
	print("do_teleport_animation called")
	anim_player.play("Teleport")


## reset animation
func _on_animation_end(_old_anim):
	anim_player.play("Idle")
