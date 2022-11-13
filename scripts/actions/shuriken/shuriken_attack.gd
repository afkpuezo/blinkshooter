extends KinematicBody2D
class_name ShurikenAttack
## the actual shuriken projectile, NOT the Action that creates it


# child nodes
onready var shuriken_mover: ShurikenMover = $ShurikenMover
onready var movement_stats = $MovementStats
onready var sprite = $Sprite

export var sprite_rotation_speed_deg := 360

# there are passed from the Action
var target # tries to return to the player
var launch_to: Vector2
var launch_duration: float
var user setget ,get_user
func get_user(): return user

export(PackedScene) var explosion_scene


func _ready() -> void:
	launch(launch_to, launch_duration)


## launches at a speed calculated to reach the to point at about the
## duration time. speed is capped at MAX_SPEED
func launch(to: Vector2, duration: float):
	shuriken_mover.launch_towards(self, movement_stats, launch_to, duration)


func _process(delta: float) -> void:
	sprite.rotation_degrees = sprite.rotation_degrees + (sprite_rotation_speed_deg * delta)


func _physics_process(delta: float) -> void:
	if target:
		shuriken_mover.chase(
			self,
			movement_stats,
			target.position
		)


func time_out():
	Spawner.spawn_node(explosion_scene.instance(), global_position)
	die()


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
		Spawner.spawn_node(explosion_scene.instance(), global_position)
		die()
