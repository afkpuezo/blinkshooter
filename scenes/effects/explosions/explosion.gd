extends Node2D
class_name Explosion
## animation used for various explosions

# can't export these for some reason, it won't draw the sprite at all
#var white = preload("res://scenes/effects/explosions/assets/white_explosion.png")
#var green = preload("res://scenes/effects/explosions/assets/green_explosion.png")
#var red = preload("res://scenes/effects/explosions/assets/red_explosion.png")

export(Texture) var white
export(Texture) var green
export(Texture) var red

## set this to another color before adding explosion to tree
var sprite_color = white

export var tiny_scale_multiplier := 0.35
export var small_scale_multiplier := 0.5
export var medium_scale_multiplier := 0.75
export var fast_speed_mutiplier := 2.0
var anim_speed = 1.0


# ----------
# setup / mode config method
# ----------


## I don't like having all of these string params but I don't want to set
## up something more complicated
func set_explosion_mode(
	color := "white",
	size := "normal",
	speed := "normal"):

	match color:
		"white":
			sprite_color = white
		"green":
			sprite_color = green
		"red":
			sprite_color = red

	match size:
		"tiny":
			scale *= tiny_scale_multiplier
		"small":
			scale *= small_scale_multiplier
		"medium":
			scale *= medium_scale_multiplier

	match speed:
		"fast":
			anim_speed *= fast_speed_mutiplier
# end set_explosion_mode()


func _set_small_scale():
	scale *= small_scale_multiplier


func _ready() -> void:
	$Sprite.texture = sprite_color
	#$Sprite.set_texture(sprite_color)
	$AnimationPlayer.play("Explosion", -1, anim_speed)


# ----------
# 'running' methods (idk what to call it, ok)
# ----------


func _on_AnimationPlayer_animation_finished(_anim_name: String) -> void:
	queue_free()
