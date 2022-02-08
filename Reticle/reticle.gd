extends KinematicBody2D
class_name Reticle
## reticle used for player aiming
## should respond to mouse and/or controller input
## technically only for gameplay, not menus?
## Currently set as a autoload singleton


onready var sprite: Sprite = $Sprite
onready var cursor_image: Texture = sprite.texture
onready var vis_nodes_array: Array = $VisNodes.get_children()
onready var state_machine: StateMachine = $StateMachine

export var SCREEN_MARGIN = 100


## start in mouse state (temp)
## place vis nodes
func _ready() -> void:
	vis_nodes_array[0].position = Vector2(position.x, position.y + SCREEN_MARGIN)
	vis_nodes_array[1].position = Vector2(position.x + (SCREEN_MARGIN * 0.75), position.y) # TODO fix this
	vis_nodes_array[2].position = Vector2(position.x, position.y - SCREEN_MARGIN)
	vis_nodes_array[3].position = Vector2(position.x - SCREEN_MARGIN, position.y)


## returns the current 'true' position of the reticle
## needed because the actual reticle does not move while in MOUSE mode
func get_true_global_position() -> Vector2:
	if state_machine.current_state.has_method("get_true_global_position"):
		return state_machine.current_state.get_true_global_position()
	else:
		return Vector2.ZERO


## checks all vis nodes
func is_within_screen_margin():
	for vis in vis_nodes_array:
		if not vis.is_on_screen():
			return false
	return true
