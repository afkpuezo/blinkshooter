extends Node
class_name PlatformDisabler
## removes the parent node if the game is running on HTML (or is not)


export(String, "HTML5", "Other") var trigger_platform
export(String, "queue_free", "invisible") var method


func _ready() -> void:
	var is_html := OS.get_name() == "HTML5"
	var is_triggered := false

	if is_html:
		is_triggered = trigger_platform == "HTML5"
	else:
		is_triggered = trigger_platform == "Other"

	if is_triggered:
		print("PlatformDisabler triggered")
		if method == "queue_free":
			get_parent().queue_free()
		else:
			get_parent().visible = false
	else:
		queue_free()
