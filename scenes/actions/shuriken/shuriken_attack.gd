extends KinematicBody2D
class_name ShurikenAttack
## the actual shuriken projectile, NOT the Action that creates it


signal exploded()
signal hit()


# child nodes
onready var shuriken_mover: ShurikenMover = $ShurikenMover
onready var movement_stats = $MovementStats
onready var sprite = $Sprite
onready var forgiveness_timer: Timer = $ForgivenessTimer

export var sprite_rotation_speed_deg := 360

# there are passed from the Action
var target # tries to return to the player
var launch_to: Vector2
var launch_duration: float
var user setget ,get_user
func get_user(): return user

var chase_position # remembers last position of target


export(PackedScene) var explosion_scene


func _ready() -> void:
	launch(launch_to, launch_duration)


## launches at a speed calculated to reach the to point at about the
## duration time. speed is capped at max_speed
func launch(to: Vector2, duration: float):
	shuriken_mover.launch_towards(self, movement_stats, to, duration)


func _process(delta: float) -> void:
	sprite.rotation_degrees = sprite.rotation_degrees + (sprite_rotation_speed_deg * delta)


func _physics_process(_delta: float) -> void:
	shuriken_mover.chase(
		self,
		movement_stats,
		get_chase_position(),
		true
	)


func get_chase_position():
	if target:
		chase_position = target.position
	return chase_position


func time_out():
	emit_signal("exploded")
	die(true)


## called by various causes
func die(_has_explosion := false):
	queue_free()


## signalled from mover
## dies either way, but handles player vs wall differently
func on_collision(col: KinematicCollision2D):
	var collider = col.collider
	if PlayerBrain.is_player(collider):
		if forgiveness_timer.is_stopped():
			die()
	else: # assume wall
		emit_signal("exploded")
		die(true)


## triggered by signal, creates a small explosion
func on_dealing_damage(_victim, _amount):
	emit_signal("hit")


## the shuriken retains a reference to the player, which can cause problems after the player has
## been freed
func on_target_death():
	target = null
