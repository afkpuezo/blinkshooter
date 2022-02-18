extends KinematicBody2D
class_name Bullet
## Flies forward until it hits something or times out


func _on_Timer_timeout() -> void:
	queue_free()
