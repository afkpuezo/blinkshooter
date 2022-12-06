extends Node2D
class_name Explosion
## animation particle used for various explosions


export(Texture) var white
export(Texture) var green
export(Texture) var red
export(Texture) var orange

## set this to another color before adding explosion to tree
var sprite_color = white

var anim_speed = 1.0


# ----------
# setup / mode config method
# ----------


## I don't like having all of these string params but I don't want to set
## up something more complicated
func set_explosion_color(color := "white"):
	match color:
		"white":
			sprite_color = white
		"green":
			sprite_color = green
		"red":
			sprite_color = red
		"orange":
			sprite_color = orange


func _ready() -> void:
	$Sprite.texture = sprite_color
	$AnimationPlayer.play("Explosion", -1, anim_speed)


# ----------
# 'running' methods (idk what to call it, ok)
# ----------


func _on_AnimationPlayer_animation_finished(_anim_name: String) -> void:
	queue_free()
