extends Action
class_name WeaponCharger
## Adds a charge requirement to any weapon, only firing the actual weapon
## once the charge is full.
## Add this to the WeaponBar and add the actual weapon to this.


onready var sub_action: Action = null

onready var sprite: Sprite = $Sprite
export var charge_texture: Texture
export var min_sprite_scale := 0.0
export var max_sprite_scale := 1.0
onready var sprite_scale_diff = max_sprite_scale - min_sprite_scale

var charge := 0.0
export var max_charge := 3.0 # seconds it takes to fill up

var setup_done := false


func _ready() -> void:
	for c in get_children():
		if Action.is_action(c):
			sub_action = c
			break
	if not sub_action:
		print("WeaponCharger doesn't have an Action child!")
		queue_free()
	sprite.texture = charge_texture


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
func trigger(target: Unit = null):
	handle_charge(target)


## due to all my kludge i'm not sure what the correct entry point for charging is
func do_action():
	handle_charge()


## add to the charge, if full, trigger the action
func handle_charge(target: Unit = null):
	_setup()
	charge += get_physics_process_delta_time()

	if charge >= max_charge:
		# warning-ignore:return_value_discarded
		sub_action.trigger(target)
		charge = 0

	var scale_val = min_sprite_scale + (sprite_scale_diff * charge / max_charge)

	sprite.scale = Vector2(
		scale_val,
		scale_val
	)
