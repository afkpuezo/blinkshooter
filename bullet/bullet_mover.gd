extends Node
class_name BulletMover
## Just launches a bullet in the direction it's fired.


onready var _stats: MovementStats = owner.get_node("MovementStats")


func _ready() -> void:
	_stats.velocity = Vector2(_stats.MAX_SPEED, 0).rotated(owner.rotation)


func _physics_process(delta: float) -> void:
	_stats.velocity = owner.move_and_slide(_stats.velocity)
