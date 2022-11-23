extends Control
class_name ActionUITile
## Component of the Action UI, this models a single equipped action


export(Color) var default_modulate
export(Color) var not_ready_modulate

# keys are the actual node names of actions
# NOTE: wasn't sure how/where to have this
const types_to_textures = {
	"Default": "res://scenes/ui/action_ui/assets/blink_item.png",
	"Blink": "res://scenes/ui/action_ui/assets/blink_item.png",
	"Sawblade": "res://scenes/ui/action_ui/assets/sawblade_item.png",
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
	set_can_trigger()


## type should be the name of the Action node
func set_type(type: String):
	var texture
	if type in types_to_textures:
		texture = types_to_textures[type]
	else:
		texture = types_to_textures['Default']
	sprite.texture = texture

func set_can_trigger(value = true):
	if value:
		sprite.modulate = default_modulate
	else:
		sprite.modulate = not_ready_modulate


func set_triggered():
	anim.stop()
	anim.play("Triggered")


## takes care of formatting
func set_cooldown(amount: float):
	var text: String

	if amount == 0:
		text = ""
	elif amount >= 1:
		text = String(ceil(amount))
	else:
		text = String(amount)
		text = text.substr(1, 2) # eg 0.973 -> .9

	cooldown_label.text = text


func set_hotkey(text):
	hotkey_label.text = text
