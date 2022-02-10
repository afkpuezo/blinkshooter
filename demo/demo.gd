extends Node2D
## doing some experimenting


func _ready() -> void:
	for child in $Player.get_children():
		print(child.name)
