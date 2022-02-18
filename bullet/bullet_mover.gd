extends Node
class_name BulletMover
## Just launches a bullet in the direction it's fired.


onready var _stats: MovementStats = owner.get_node("MovementStats")


func _physics_process(delta: float) -> void:
	_stats.velocity = _stats.velocity.move_toward(Vector2(_stats.MAX_SPEED, 0), _stats.ACCELERATION * delta)
	#print("a: " + str(_stats.velocity))
	_stats.velocity = owner.move_and_slide(_stats.velocity)
	#print("b: " + str(_stats.velocity))
