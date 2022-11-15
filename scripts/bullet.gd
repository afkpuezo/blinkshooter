extends KinematicBody2D
class_name Bullet
## the root node of the generic bullet scene
## Flies forward until it hits something or times out


export var has_explosion := true
export(String, "white", "green", "red") var explosion_color = "white"
export(String, "small", "normal") var explosion_size = "normal"
export(String, "normal", "fast") var explosion_speed = "normal"

export(PackedScene) var explosion_scene

# I've messed up something with the inheritence to make this necessary
export var shape_x := 1
export var shape_y := 1

## damage dealt to target when hit, set by weapon
var damage = 1

## the unit responsible for shooting this bullet
var source


func _ready() -> void:
	# I've messed up something with the inheritence to make this necessary
	var col_shapes = [$CollisionShape2D, $HitBox/CollisionShape2D]
	for col_shape in col_shapes:
		col_shape.shape.extents.x = shape_x
		col_shape.shape.extents.y = shape_y

## maybe overkill, but acts as interface between the outside and inside?
func set_initial_velocity(initial_velocity: Vector2):
	$BulletMover.set_initial_velocity(initial_velocity)


func _on_Timer_timeout() -> void:
	queue_free()


## handles collisions with things that can be hurt, EG units
func _on_HitBox_area_entered(area) -> void:
	#print("DEBUG: bullet hitbox area entered by: %s" % area.name)
	if area.has_method("get_unit"):
		var victim = area.get_unit()
		victim.take_damage(damage, source)
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
	if has_explosion:
		var explosion = explosion_scene.instance()
		if explosion.has_method("set_explosion_mode"):
			explosion.set_explosion_mode(
				explosion_color,
				explosion_size,
				explosion_speed
			)

		Spawner.spawn_node(explosion, global_position)
	# end if explosion_mode
	queue_free()
