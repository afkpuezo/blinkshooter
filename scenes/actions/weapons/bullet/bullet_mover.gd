extends Node
class_name BulletMover
## Just launches a bullet in the direction it's fired.


signal collided(collision)


onready var _stats = owner.get_node("MovementStats")
var initial_velocity: Vector2 = Vector2.ZERO


func set_initial_velocity(i_v: Vector2):
	initial_velocity = i_v


func _ready() -> void:
	var vel = Vector2(_stats.max_speed, 0).rotated(owner.rotation)
	vel = vel + initial_velocity
	_stats.velocity = vel


func _physics_process(delta: float) -> void:
	# uses move_and_collide because we need the collision object
	var collision: KinematicCollision2D = owner.move_and_collide(_stats.velocity * delta)
	if collision:
		emit_signal("collided", collision)
