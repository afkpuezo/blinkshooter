extends Node2D
class_name SawBladeAttack
## this scene/node is the actual blade with the sprite and hurtbox, but not the
## action that uses/creates it

var was_ready_called := false
var user
func get_user(): return user # KLUUUUUUDGE

export var sprite_rotation_speed_deg = 720 # per second?

# child nodes
onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var spin_anim: Animation = animation_player.get_animation("spin")
onready var sprite: Sprite = $Sprite


func _ready() -> void:
	was_ready_called = true


## called when entering tree
func start() -> void:
	# if called before ready, onready vars aren't set yet
	if was_ready_called:
		# in case the animation is still playing from before
		animation_player.stop(true)
		animation_player.play("spin")


## Checking collisions happens here because an enemy could stay in the hit box
## and continue to take damage (rather than using an on_entered signal)
func _physics_process(delta: float) -> void:
	handle_sprite_rotation(delta)


func handle_sprite_rotation(delta):
	sprite.rotate(deg2rad(sprite_rotation_speed_deg * delta))
