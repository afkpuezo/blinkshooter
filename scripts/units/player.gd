extends Unit
class_name Player
## primary player controller


onready var anim_player: AnimationPlayer = $AnimationPlayer

export(Array, PackedScene) var starting_actions
export(Array, PackedScene) var starting_weapons


# ----------
# static funcs
# ----------


## Overkill for now, might be more correct later if code gets more complicated
static func is_player(n: Node):
	return n != null and n.has_method("_is_player_help")


## Currently used by enemies to figure out who an attack came from.
## I kludged it so that bullets have the player as a source but the attacks
## from actions (such as the shuriken) point to the action node.
## This method will handle both cases.
## Returns the player node if it is the source of this attack, otherwise
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
	_setup_starting_actions()
	_setup_starting_weapons()

	GameEvents.emit_signal("player_spawned", {'player': self})


func _setup_starting_actions():
	var action_bar = $ActionBar
	for scene in starting_actions:
		var action = scene.instance()
		action_bar.add_action(action)


func _setup_starting_weapons():
	var weapon_bar = $WeaponBar
	for scene in starting_weapons:
		var weapon = scene.instance()
		weapon_bar.add_weapon(weapon)


# ----------
# instance-level methods
# ----------


## can't use the Player class in this script, looking for this method will do the same thing
## pretty gross
func _is_player_help() -> bool:
	return true


func setup_mover() -> Mover:
	var mover = $InputMover
	return mover


## from Unit
func die():
	GameEvents.emit_signal("player_died", {'player': self})
	.die()


## call the animation on the animation player
func do_teleport_animation():
	anim_player.play("Teleport")


## reset animation
func _on_animation_end(_old_anim):
	anim_player.play("Idle")


## the fact that I have to extend this makes me think I'm doing something wrong
func take_damage(amount, source) -> void:
	#print("DEBUG: enemy taking damage: %d" % amount)
	.take_damage(amount, source)
