extends KinematicBody2D
class_name ShurikenAttack
## the actual shuriken projectile, NOT the Action that creates it


# child nodes
onready var shuriken_mover: ShurikenMover = $ShurikenMover
onready var movement_stats = $MovementStats
onready var sprite = $Sprite

export var sprite_rotation_speed_deg := 360
var target # tries to return to the player
var launch_to: Vector2


func _ready() -> void:
	launch(launch_to)


## launches at full speed to the launch_to point, then follows the target until
## expiring
func launch(launch_to: Vector2):
	shuriken_mover.launch_towards(self, movement_stats, launch_to)


func _process(delta: float) -> void:
	sprite.rotation_degrees = sprite.rotation_degrees + (sprite_rotation_speed_deg * delta)


func _physics_process(delta: float) -> void:
	if target:
		shuriken_mover.chase(
			self,
			movement_stats,
			target.position
		)


## called by various causes
func die():
	queue_free()


## signalled from mover
## dies either way, but handles player vs wall differently
func on_collision(col: KinematicCollision2D):
	var collider = col.collider
	#print("DEBUG: shuriken colliding with %s" % collider.name)
	if Player.is_player(collider):
		die()
	else: # assume wall
		die()
