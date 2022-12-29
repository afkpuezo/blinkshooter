extends Node2D
class_name Lock
## Add this to a gateway to lock it. This will emit a signal when it is unlocked
## Can be set to unlock when the player touches it, and/or when a specified
## group of enemies is killed (add the enemies as children of the lock)


signal unlocked()


export var require_touch := true
onready var was_touched := !require_touch
var num_units_left := 0


func _ready() -> void:
	for c in get_children():
		if c is Unit:
			num_units_left += 1
			c.connect("died", self, "on_unit_death")

	update()


func on_touch(_u):
	was_touched = true
	update()


func on_unit_death():
	num_units_left -= 1
	update()


func update():
	if was_touched and num_units_left == 0:
		emit_signal("unlocked")
