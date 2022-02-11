extends Node
class_name ActionBar
## Acts as an interface between the player node and the actions they can perform
## NOTE: this is currently a placeholder


onready var user := get_parent() # gross


func _ready() -> void:
	for action in get_children():
		action.configure_user(user)
