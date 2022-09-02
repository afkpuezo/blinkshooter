extends Unit
class_name Enemy
## VERY placeholder right now

onready var player_detection = $PlayerDetection

# -
# ----------
# inherited from Node2D
# ----------
# -

## TODO remove this?
func _physics_process(delta: float) -> void:
	#var velocity = move_and_slide(Vector2.ZERO) # wont collide if not doing this?
	var velocity = move_and_collide(Vector2.ZERO)

# -
# ----------
# inherited from Unit
# ----------
# -

## the fact that I have to extend this makes me think I'm doing something wrong
func _check_for_death(new_health_value) -> void:
	._check_for_death(new_health_value)


## the fact that I have to extend this makes me think I'm doing something wrong
func take_damage(amount, source) -> void:
	#print("DEBUG: enemy taking damage: %d" % amount)
	.take_damage(amount, source)

# -
# ----------
# new in Enemy
# ----------
# -


# ----------
# player-detection related
# ----------


## Returns null if the player is not currently in the detection area
func get_player_if_detected() -> Player:
	var overlaps = player_detection.get_overlapping_bodies() # should be areas?
	for n in overlaps:
#		print("DEBUG: EnemyMover.physics_update() found node in overlapping bodies: %s" % n.name)
		if n is Player:
			return n
	return null


## is this redundant?
func has_detected_player() -> bool:
	return get_player_if_detected() != null
