extends Node2D
class_name Gateway
## teleports the player to a specified target location
## configure it by adding a destination and optionally a lock


var destination: GatewayDestination

# these vars may be changed in ready
var num_locks_remaining := 0
var is_unlocked := false


func _ready() -> void:
	for c in get_children():
		if c is GatewayDestination:
			destination = c

		if c is Lock:
			num_locks_remaining += 1
			c.connect("unlocked", self, "on_lock_unlock")
	# end for children
	if not destination:
		print("%s couldn't find a destination!" % name)

	update()


func on_unit_entered(unit: Unit):
	if is_unlocked:
		unit.global_position = destination.global_position


func on_lock_unlock():
	num_locks_remaining -= 1
	update()


func update():
	if num_locks_remaining == 0:
		is_unlocked = true
