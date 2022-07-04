extends KinematicBody2D
class_name Bullet
## the root node of the generic bullet scene
## Flies forward until it hits something or times out


func _on_Timer_timeout() -> void:
	queue_free()
