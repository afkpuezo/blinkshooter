extends Node2D
class_name SawBlade
## this scene/node is the actual blade with the sprite and hurtbox, but not the
## action that uses/creates it

# child nodes
onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var spin_anim: Animation = animation_player.get_animation("spin")


func _ready() -> void:
	spin_anim.set_loop(true)
	animation_player.play("spin")
