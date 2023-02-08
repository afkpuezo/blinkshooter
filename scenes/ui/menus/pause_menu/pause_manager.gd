extends CanvasLayer
# no class for singletons
## handles pausing and displaying menu


signal button_pressed()


export var main_menu_scene_path := "res://scenes/ui/menus/main_menu/main_menu.tscn"

var is_pausable := true setget set_is_pausable


func set_is_pausable(new_val: bool):
	is_pausable = new_val
	if not is_pausable:
		resume() # should be ok if already unpaused


func _process(_delta: float) -> void:
	if is_pausable:
		if get_tree().paused:
			if Input.is_action_just_pressed("pause"):
				resume()
			elif Input.is_action_just_pressed("quit"):
				get_tree().quit()
		else: # not paused
			if Input.is_action_just_pressed("pause"):
				pause()


func pause():
	get_tree().paused = true
	visible = true


func resume():
	#emit_signal("button_pressed")
	get_tree().paused = false
	visible = false


func go_to_start_screen():
	emit_signal("button_pressed")
	GameEvents.emit_signal("returned_to_main_menu", {})
	# warning-ignore:return_value_discarded
	get_tree().change_scene(main_menu_scene_path)


func quit():
	emit_signal("button_pressed")
	get_tree().quit()
