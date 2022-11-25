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
	"Default": "res://scenes/ui/player_ui/action_ui/assets/blink_item.png",
	"Blink": "res://scenes/ui/player_ui/action_ui/assets/blink_item.png",
	"SawBlade": "res://scenes/ui/player_ui/action_ui/assets/sawblade_item.png",
	"Shuriken": "res://scenes/ui/player_ui/action_ui/assets/shuriken_item.png",
	"SmallGun": "res://scenes/ui/player_ui/action_ui/assets/small_gun_item.png",
	"BigGun": "res://scenes/ui/player_ui/action_ui/assets/big_gun_item.png",
}

# child nodes
onready var texture_rect: TextureRect = $TextureRect
onready var anim: AnimationPlayer = $AnimationPlayer
onready var cooldown_label: Label = $CooldownLabel
onready var hotkey_label: Label = $HotkeyLabel


func _ready() -> void:
	set_is_ready()


## type should be the name of the Action node
## should be called AFTER ready
func set_type(new_type: String):
	#print("set_type called with new_type: %s" % new_type)
	type = new_type
	var texture
	if type in types_to_textures:
		texture = types_to_textures[type]
	else:
		texture = types_to_textures['Default']
	texture_rect.texture = load(texture)


func set_is_ready(value = true):
	if value:
		texture_rect.modulate = default_modulate
	else:
		texture_rect.modulate = not_ready_modulate


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
	hotkey_label.text = String(text)


func set_min_size_scale_factor(factor):
	for n in [self, texture_rect, cooldown_label, hotkey_label]:
		n.rect_min_size = n.rect_min_size * factor
		if n == self and factor < 1:
			print("reverted rect_min_size to %s" % n.rect_min_size)
