extends KinematicBody2D
class_name Bullet
## the root node of the generic bullet scene
## Flies forward until it hits something or times out


## damage dealt to target when hit, set by weapon
var damage = 1


## maybe overkill, but acts as interface between the outside and inside?
func set_initial_velocity(initial_velocity: Vector2):
	$BulletMover.set_initial_velocity(initial_velocity)


func _on_Timer_timeout() -> void:
	queue_free()


## handles collisions with things that can be hurt, EG units
func _on_HitBox_area_entered(area) -> void:
	#print("DEBUG: bullet hitbox area entered by: %s" % area.name)
	if area is HurtBox:
		area.take_damage(damage, self)
		_handle_hit()
	else:
		#print("DEBUG: Bullet._on_HitBox_area_entered() passed a non-HurtBox area: %s" % area.name)
		pass


## handles collisions with things that aren't hurt, like walls
## NOTE: just assumes that anything in the Wall collision layer (1) is a wall
func _on_BulletMover_collided(_collision: KinematicCollision2D) -> void:
	_handle_hit() # at some point, explode on the wall or something


## EG if there are animations that play on hitting a unit or wall
func _handle_hit():
	queue_free()
