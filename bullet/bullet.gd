extends KinematicBody2D
class_name Bullet
## the root node of the generic bullet scene
## Flies forward until it hits something or times out


## damage dealt to target when hit
export var damage = 1


## maybe overkill, but acts as interface between the outside and inside?
func set_initial_velocity(initial_velocity: Vector2):
	$BulletMover.set_initial_velocity(initial_velocity)


func _on_Timer_timeout() -> void:
	queue_free()


func _on_HitBox_area_entered(area) -> void:
	#print("DEBUG: bullet hitbox area entered by: %s" % area.name)
	if area is HurtBox:
		area.take_damage(damage, self)
		queue_free()
	else:
		print("DEBUG: Bullet._on_HitBox_area_entered() passed a non-HurtBox area: %s" % area.name)
