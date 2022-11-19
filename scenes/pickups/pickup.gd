extends Area2D
class_name Pickup
## holds an item for the player to pick up by walking over it


export(PackedScene) var item_scene
export var radius := 32
export(Texture) var sprite_texture

var done := false


func _ready() -> void:
	$CollisionShape2D.shape.radius = radius
	$Sprite.texture = sprite_texture


func get_item():
	done = true # wtb finally
	return item_scene.instance()


func _process(_delta: float) -> void:
	if done:
		queue_free()
