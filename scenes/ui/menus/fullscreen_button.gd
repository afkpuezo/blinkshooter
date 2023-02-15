extends Button
class_name FullScreenButton
## guess I am making a scene for this


func on_pressed() -> void:
	OS.window_fullscreen = !OS.window_fullscreen
