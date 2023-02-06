extends StaticBody2D
class_name Lock
## Add this to a gateway to lock it. This will emit a signal when it is unlocked
## Can be set to unlock when the player touches it, and/or when a specified
## group of enemies is killed (add the enemies as children of the lock)


signal unlocked()


onready var sprite: Sprite = $Sprite
onready var label: Label = $CenterContainer/HBoxContainer/Label
onready var texture_rect: TextureRect = $CenterContainer/HBoxContainer/TextureRect

var is_unlocked := false
enum UNLOCK_MODE{TOUCH, KILL}
var mode: int = UNLOCK_MODE.TOUCH
var was_touched := false
var num_units_left := 0

export var open_sprite: Texture
export var locked_touch_sprite: Texture
export var locked_enemy_sprite: Texture


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
	# don't bother re-emitting unlock signal
	if is_unlocked:
		return

	if num_units_left > 0:
		label.text = String(num_units_left)
		label.visible = true
		texture_rect.visible = true
	else:
		label.visible = false
		texture_rect.visible = false

	var temp_texture: Texture

	match mode:
		UNLOCK_MODE.TOUCH:
			is_unlocked = was_touched
			temp_texture = locked_touch_sprite
		UNLOCK_MODE.KILL:
			is_unlocked = num_units_left == 0
			temp_texture = locked_enemy_sprite

	if is_unlocked:
		emit_signal("unlocked")
		temp_texture = open_sprite

	sprite.texture = temp_texture
