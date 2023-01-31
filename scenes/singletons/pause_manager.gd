extends CanvasLayer
# no class for singletons
## handles pausing and displaying menu


var is_pausable := true setget set_is_pausable


func set_is_pausable(new_val: bool):
	is_pausable = new_val
	if not is_pausable:
		get_tree().paused = false


func _process(_delta: float) -> void:
	if is_pausable:
		if get_tree().paused:
			if Input.is_action_just_pressed("pause"):
				get_tree().paused = false
				visible = false
			elif Input.is_action_just_pressed("quit"):
				get_tree().quit()
		else: # not paused
			if Input.is_action_just_pressed("pause"):
				get_tree().paused = true
				visible = true
