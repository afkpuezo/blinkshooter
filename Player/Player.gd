extends KinematicBody2D
class_name Player
## primary player controller


# movement speed values
onready var input_based_mover: InputBasedMover = $InputBasedMover


## currently takes care of movement itself
## will likely get changed to a state machine later
## also controls direction
func _physics_process(delta: float) -> void:
	input_based_mover.physics_update(delta)

	look_at(TargetReticle.get_true_global_position())


## if the new amount is 0, we ded
func _check_for_death(new_health_value) -> void:
	if new_health_value == 0:
		GameEvents.emit_signal("player_died")
		queue_free()
