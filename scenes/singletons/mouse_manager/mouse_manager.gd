extends Node2D
# singleton
## handles mouse confinement, etc
## this node WILL process while the game is paused
# also handles fullscreen toggling


onready var is_html := OS.get_name() == 'HTML5'
onready var sprite: Sprite = $Sprite


func _ready() -> void:
	if is_html:
		sprite.visible = true
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		sprite.global_position = get_global_mouse_position()


func _process(_delta: float) -> void:
	if is_html:
		sprite.global_position = get_global_mouse_position()
	else:
		if PauseManager.is_pausable: # regular level
			if get_tree().paused:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			else:
				Input.mouse_mode = Input.MOUSE_MODE_CONFINED
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

