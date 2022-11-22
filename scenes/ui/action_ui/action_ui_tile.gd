extends Control
class_name ActionUITile
## Component of the Action UI, this models a single equipped action


export(Color) var default_modulate
export(Color) var not_ready_modulate


# child nodes
onready var sprite: Sprite = $Sprite
onready var anim: AnimationPlayer = $AnimationPlayer
onready var cooldown_label: Label = $CooldownLabel
onready var hotkey_label: Label = $HotkeyLabel


func _ready() -> void:
	set_ready()


func set_ready():
	sprite.modulate = default_modulate


func set_not_ready():
	sprite.modulate = not_ready_modulate


func set_triggered():
	anim.stop()
	anim.play("Triggered")


## takes care of formatting
func set_cooldown(amount: float):
	var text: String

	if amount >= 1:
		text = String(ceil(amount))
	else:
		text = String(amount)
		text = text.substr(1, 2) # eg 0.973 -> .9

	cooldown_label.text = text


func set_hotkey(text):
	hotkey_label.text = text
