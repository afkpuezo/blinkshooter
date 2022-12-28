extends Node2D
class_name Gateway
## teleports the player to a specified target location
## configure it by adding a destination and optionally a lock


var destination: GatewayDestination


func _ready() -> void:
	for c in get_children():
		if c is GatewayDestination:
			destination = c
			break
	if not destination:
		print("%s couldn't find a destination!" % name)


func on_unit_entered(unit: Unit):
	unit.global_position = destination.global_position
