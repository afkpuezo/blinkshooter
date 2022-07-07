extends KinematicBody2D
class_name Enemy
## VERY placeholder right now


func _physics_process(delta: float) -> void:
	#var velocity = move_and_slide(Vector2.ZERO) # wont collide if not doing this?
	var velocity = move_and_collide(Vector2.ZERO)
