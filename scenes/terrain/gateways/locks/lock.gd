extends Node2D
class_name Lock
## Add this to a gateway to lock it. This will emit a signal when it is unlocked
## Can be set to unlock when the player touches it, and/or when a specified
## group of enemies is killed (add the enemies as children of the lock)


signal unlocked()


onready var sprite: Sprite = $Sprite

enum UNLOCK_MODE{TOUCH, KILL}
var mode: int = UNLOCK_MODE.TOUCH
var was_touched := false
var num_units_left := 0

export var open_sprite: Texture
export var locked_sprite: Texture


func _ready() -> void:
	for c in get_children():
		if c is Unit:
			num_units_left += 1
			c.connect("died", self, "on_unit_death")

	if num_units_left > 0:
		mode = UNLOCK_MODE.KILL

	update()


func on_touch(_u):
	was_touched = true
	update()


func on_unit_death():
	num_units_left -= 1
	update()


func update():
	var unlocked: bool
	match mode:
		UNLOCK_MODE.TOUCH:
			unlocked = was_touched
		UNLOCK_MODE.KILL:
			unlocked = num_units_left == 0

	if unlocked:
		emit_signal("unlocked")
		sprite.texture = open_sprite
	else:
		sprite.texture = locked_sprite
