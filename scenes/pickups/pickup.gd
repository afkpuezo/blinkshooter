extends Node2D
class_name Pickup
## Base class for various pickup items that the player can grab


# exports
export var pickup_radius := 64
export(Texture) var sprite_texture
export(PackedScene) var item_scene # the scene of the actual item to be given


func _ready() -> void:
	$Sprite.texture = sprite_texture
	$Area2D/CollisionShape2D.shape.radius = pickup_radius


func get_item():
	return item_scene.instance()
