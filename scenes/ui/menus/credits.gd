extends Control
class_name Credits
## this technically isn't a menu but I'm putting it in the folder anyway


export var main_menu_scene_path := "res://scenes/ui/menus/main_menu/main_menu.tscn"


func _ready() -> void:
	PauseManager.is_pausable = false
	$AnimationPlayer.play("Scroll")


## esc key to quit early
func _process(_delta: float) -> void:
	for code in ["pause_esc", "pause_f1"]:
		if Input.is_action_just_pressed(code):
			back_to_start_menu()


func _on_AnimationPlayer_animation_finished(_anim_name: String) -> void:
	back_to_start_menu()


func back_to_start_menu():
	GameEvents.emit_signal("returned_to_main_menu", {})
	# warning-ignore:return_value_discarded
	get_tree().change_scene(main_menu_scene_path)
