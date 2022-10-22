extends Unit
class_name Player
## primary player controller


# movement speed values
#onready var input_mover: InputMover = $InputMover
onready var anim_player: AnimationPlayer = $AnimationPlayer


# ----------
# static funcs		if should_attack():		if should_attack():
# ----------


## Overkill for now, might be more correct later if code gets more complicated
static func is_player(n: Node): return n.has_method("_is_player_help")


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


## if the new amount is 0, we ded
func _check_for_death(new_health_value) -> void:
	if new_health_value == 0:
		GameEvents.emit_signal("player_died")
		queue_free()


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
