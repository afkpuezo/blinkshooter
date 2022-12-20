extends Mover
class_name BulletMover
## Just launches a bullet in the direction it's fired.


onready var stats = owner.get_node("MovementStats")
var initial_velocity: Vector2 = Vector2.ZERO
var is_initial_velocity_set := false


func set_initial_velocity(i_v: Vector2):
	initial_velocity = i_v
	is_initial_velocity_set = true


func start_movement() -> void:
	var vel = Vector2(stats.max_speed, 0).rotated(owner.rotation)
	vel = vel + initial_velocity
	stats.velocity = vel


func _physics_process(delta: float) -> void:
	if is_initial_velocity_set:
		start_movement()
		is_initial_velocity_set = false
	# uses move_and_collide because we need the collision object

	if owner.is_homing and owner.target:
		chase(
			owner,
			stats,
			owner.target.global_position
		)
	else:
		move_subject(owner, stats, true)
