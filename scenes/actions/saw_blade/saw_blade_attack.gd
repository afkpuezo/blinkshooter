extends Node2D
class_name SawBladeAttack
## this scene/node is the actual blade with the sprite and hurtbox, but not the
## action that uses/creates it


signal dealt_damage(victim, amount)
signal hit_at(hit_position)


var was_ready_called := false
var user
func get_user(): return user # KLUUUUUUDGE

export var sprite_rotation_speed_deg = 720 # per second?

export var blade_radius := 56 # used to determine hit position

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


func _on_AreaOverTimeAttack_dealt_damage(victim, amount) -> void:
	emit_signal("dealt_damage", victim, amount)
	emit_signal(
		"hit_at",
		calculate_hit_position(victim.global_position)
	)


## figure out where to place the hit explosion for this enemy
func calculate_hit_position(victim_global_position: Vector2) -> Vector2:
	var direction = global_position.direction_to(victim_global_position)
	return global_position + (direction * blade_radius)
