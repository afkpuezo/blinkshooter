extends Control
class_name ActionUITile
## Component of the Action UI, this models a single equipped action

var type: String = "Default"

export(Color) var default_modulate
export(Color) var not_ready_modulate

export var min_cooldown_threshold := 0.1 # 0 if it ever ticks < this
export var min_start_cooldown_threshold := 0.5 # ignore cooldown if it goes from 0 to this
export var no_decimal_threshold := 2.0 # only draw whole number if >= this
var current_cooldown := 0.0

# is there a better way to copy?
export var current_slot_scale_factor := 1.5
onready var original_min_size := Vector2(rect_min_size[0], rect_min_size[1])

# keys are the actual node names of actions
# NOTE: wasn't sure how/where to have this, exporting a dict is weird
const types_to_textures = {
	"Default": "res://scenes/ui/player_ui/action_ui/assets/blink_item.png",
	"Blink": "res://scenes/ui/player_ui/action_ui/assets/blink_item.png",
	"SawBlade": "res://scenes/ui/player_ui/action_ui/assets/sawblade_item.png",
	"Shuriken": "res://scenes/ui/player_ui/action_ui/assets/shuriken_item.png",
	"SmallGun": "res://scenes/ui/player_ui/action_ui/assets/small_gun_item_oj.png",
	"BigGun": "res://scenes/ui/player_ui/action_ui/assets/big_gun_item_oj.png",
}

# child nodes
onready var texture_rect: TextureRect = $TextureRect
onready var anim: AnimationPlayer = $AnimationPlayer
onready var cooldown_label: Label = $CooldownLabel
onready var hotkey_label: Label = $HotkeyLabel
onready var ammo_label: Label = $AmmoLabel


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

	if current_cooldown == 0 and amount < min_start_cooldown_threshold:
		current_cooldown = 0
	elif amount < min_cooldown_threshold:
		current_cooldown = 0
	elif amount >= no_decimal_threshold:
		current_cooldown = ceil(amount)
	else:
		current_cooldown = amount

	if current_cooldown == 0:
		text = ""
	else:
		text = String(current_cooldown).substr(0, 3)

	cooldown_label.text = text


func set_hotkey(text):
	hotkey_label.text = String(text)


func set_min_size_scale_factor(factor):
	original_min_size = original_min_size * factor
	rect_min_size = rect_min_size * factor


## used to show which weapon is currently selected
func set_current_slot(value: bool = true):
	if value:
		rect_min_size = original_min_size * current_slot_scale_factor
	else:
		rect_min_size = original_min_size


## no formatting on this one (yet)
func set_ammo_amount(amount: int):
	ammo_label.text = String(amount)
