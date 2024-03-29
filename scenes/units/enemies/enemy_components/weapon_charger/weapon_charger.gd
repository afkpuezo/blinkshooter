extends Action
class_name WeaponCharger
## Adds a charge requirement to any weapon, only firing the actual weapon
## once the charge is full.
## Add this to the WeaponBar and add the actual weapon to this.
## NOTE: this is still a weapon NODE, not the new scene!


var sub_action: Action
var audio_helper: AudioHelper

onready var sprite: Sprite = $Sprite
export var charge_texture: Texture
export var min_sprite_scale := 0.0
export var max_sprite_scale := 1.0
onready var sprite_scale_diff = max_sprite_scale - min_sprite_scale

var charge := 0.0
export var max_charge := 3.0 # seconds it takes to fill up
var was_charge_gained_this_frame := false

var setup_done := false


func _ready() -> void:
	for c in get_children():
		if Action.is_action(c):
			sub_action = c
		# jankludge
		if c is AudioHelper:
			audio_helper = c
	if not sub_action:
		print("WeaponCharger doesn't have an Action child!")
		queue_free()
	sprite.texture = charge_texture
	_scale_sprite()


## stuff that can't be done in ready
func _setup():
	if setup_done:
		return
	else:
		setup_done = true
		sub_action.configure_user(user)
		var charge_point = BulletSpawnPoint.get_bullet_spawn_point(user)
		if charge_point:
			remove_child(sprite)
			charge_point.add_child(sprite)


## due to all my kludge i'm not sure what the correct entry point for charging is
func trigger(_target: Unit = null):
	gain_charge()


## due to all my kludge i'm not sure what the correct entry point for charging is
func do_action():
	gain_charge()


## add to the charge, if full, trigger the action
func gain_charge():
	_setup()
	charge += get_physics_process_delta_time()
	was_charge_gained_this_frame = true

	if charge >= max_charge:
		# warning-ignore:return_value_discarded
		sub_action.trigger(target)
		charge = 0

	_scale_sprite()
	if audio_helper and charge > 0:
		audio_helper.play_from_percent(
			charge / max_charge,
			false # don't start playing again if already playing
		)


func _scale_sprite():
	var scale_val = min_sprite_scale + (sprite_scale_diff * charge / max_charge)

	sprite.scale = Vector2(
		scale_val,
		scale_val
	)


## handles losing charge while not being called
func _physics_process(_delta: float) -> void:
	if not was_charge_gained_this_frame:
		charge = max(0.0, charge - get_physics_process_delta_time())
		_scale_sprite()

	was_charge_gained_this_frame = false
