extends Node2D
class_name TeleportEffect
## shows a little blue circle portal things when the player teleports


export var anim_speed := 1.0
var debug_time := 0.0


func _ready() -> void:
	$AnimationPlayer.play(
		"Teleport",
		-1, # blend
		anim_speed
	)
	print("ready() for %s" % name)


func _on_AnimationPlayer_animation_finished(_anim_name: String) -> void:
	print("finished() for %s, lifespan: %f" % [name, debug_time])
	queue_free()


func _physics_process(delta: float) -> void:
	debug_time += delta
