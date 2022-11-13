extends Node2D
class_name Explosion
## animation used for various explosions


func _ready() -> void:
	$AnimationPlayer.play("Explosion")


func _on_AnimationPlayer_animation_finished(_anim_name: String) -> void:
	queue_free()
