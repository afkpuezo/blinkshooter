extends Unit
class_name Enemy
## VERY placeholder right now


func _physics_process(delta: float) -> void:
	#var velocity = move_and_slide(Vector2.ZERO) # wont collide if not doing this?
	var velocity = move_and_collide(Vector2.ZERO)


## the fact that I have to extend this makes me think I'm doing something wrong
func _check_for_death(new_health_value) -> void:
	._check_for_death(new_health_value)


## the fact that I have to extend this makes me think I'm doing something wrong
func take_damage(amount, source) -> void:
	print("DEBUG: enemy taking damage: %d" % amount)
	.take_damage(amount, source)
