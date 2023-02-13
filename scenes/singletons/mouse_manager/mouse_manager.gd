extends Node2D
# singleton
## handles mouse confinement, etc
## this node WILL process while the game is paused


onready var is_html := OS.get_name() == 'HTML5'


func _process(_delta: float) -> void:
	if PauseManager.is_pausable: # regular level
		if get_tree().paused:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

