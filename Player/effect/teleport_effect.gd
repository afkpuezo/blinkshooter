extends Node2D
class_name TeleportEffect
## shows a little blue circle portal things when the player teleports


func _ready() -> void:
	$AnimationPlayer.play("Teleport")


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	queue_free()
