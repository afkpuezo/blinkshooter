extends CanvasLayer
# no class for singletons
## handles pausing and displaying menu


onready var margin_container := $MarginContainer

var is_paused := false # should I just use the get_tree var?


func _process(delta: float) -> void:
	if is_paused:
		if Input.is_action_just_pressed("pause"):
			is_paused = false
			get_tree().paused = false
			margin_container.visible = false
		elif Input.is_action_just_pressed("quit"):
			get_tree().quit()
	else: # not paused
		if Input.is_action_just_pressed("pause"):
			is_paused = true
			get_tree().paused = true
			margin_container.visible = true