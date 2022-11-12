extends Node2D
class_name ShurikenAttack
## the actual shuriken projectile, NOT the Action that creates it


# child nodes
onready var shuriken_mover: ShurikenMover = $ShurikenMover
onready var movement_stats = $MovementStats

export var sprite_rotation_speed_deg := 360
var target # tries to return to the player
var launch_to: Vector2


func _ready() -> void:
	launch(launch_to)


## launches at full speed to the launch_to point, then follows the target until
## expiring
func launch(launch_to: Vector2):
	shuriken_mover.launch_towards(self, movement_stats, launch_to)


func _physics_process(delta: float) -> void:
	if target:
		shuriken_mover.chase(
			self,
			movement_stats,
			target.position
		)
