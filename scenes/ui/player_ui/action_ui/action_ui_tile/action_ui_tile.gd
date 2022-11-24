extends Control
class_name ActionUITile
## Component of the Action UI, this models a single equipped action

var type: String = "Default"

export(Color) var default_modulate
export(Color) var not_ready_modulate

export var no_cooldown_threshold := 0.1

# keys are the actual node names of actions
# NOTE: wasn't sure how/where to have this, exporting a dict is weird
const types_to_textures = {
	"Default": "res://scenes/ui/action_ui/assets/blink_item.png",
	"Blink": "res://scenes/ui/action_ui/assets/blink_item.png",
	"SawBlade": "res://scenes/ui/action_ui/assets/sawblade_item.png",
	"Shuriken": "res://scenes/ui/action_ui/assets/shuriken_item.png",
	"SmallGun": "res://scenes/ui/action_ui/assets/small_gun_item.png",
	"BigGun": "res://scenes/ui/action_ui/assets/big_gun_item.png",
}

# child nodes
onready var sprite: Sprite = $Sprite
onready var anim: AnimationPlayer = $AnimationPlayer
onready var cooldown_label: Label = $CooldownLabel
onready var hotkey_label: Label = $HotkeyLabel


func _ready() -> void:
	set_is_ready()
	var texture
	if type in types_to_textures:
		texture = types_to_textures[type]
	else:
		texture = types_to_textures['Default']
	sprite.texture = load(texture)


## type should be the name of the Action node
## should be called BEFORE ready
func set_type(new_type: String):
	print("set_type called with new_type: %s" % new_type)
	type = new_type


func set_is_ready(value = true):
	if value:
		sprite.modulate = default_modulate
	else:
		sprite.modulate = not_ready_modulate


func set_was_triggered(value = false):
	if value:
		anim.stop()
		anim.play("Triggered")


## takes care of formatting
func set_cooldown(amount: float):
	var text: String

	if amount == 0 or amount < no_cooldown_threshold:
		text = ""
	elif amount >= 1:
		text = String(ceil(amount))
	else:
		text = String(amount)
		text = text.substr(1, 2) # eg 0.973 -> .9

	cooldown_label.text = text


func set_hotkey(text):
	hotkey_label.text = text
