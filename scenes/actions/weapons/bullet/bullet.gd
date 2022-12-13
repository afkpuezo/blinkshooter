extends KinematicBody2D
class_name Bullet
## the root node of the generic bullet scene
## Flies forward until it hits something or times out


signal exploded()


export var has_explosion := true


## damage dealt to target when hit, set by weapon
var damage = 1

## the unit responsible for shooting this bullet
var source


## maybe overkill, but acts as interface between the outside and inside?
func set_initial_velocity(initial_velocity: Vector2):
	$BulletMover.set_initial_velocity(initial_velocity)


## handles collisions with things that can be hurt, EG units
func _on_HitBox_area_entered(area) -> void:
	if area.has_method("get_unit"):
		var victim: Unit = area.get_unit()
		victim.take_damage(damage, source)
		end()


func end(do_explode := has_explosion):
	if do_explode:
		emit_signal("exploded")
	queue_free()
