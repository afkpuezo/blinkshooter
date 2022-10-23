extends Node2D
class_name SawBladeAttack
## this scene/node is the actual blade with the sprite and hurtbox, but not the
## action that uses/creates it

var damage_cooldown_scene = load("res://scenes/buffs/damage_cooldown.tscn")

var was_ready_called := false

export var damage := 30 # should this be set in the action scene?
export var damage_cooldown := 0.5

export var sprite_rotation_speed_deg = 720 # per second?

# child nodes
onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var spin_anim: Animation = animation_player.get_animation("spin")
onready var hit_box: HitBox = $HitBox
onready var sprite: Sprite = $Sprite


func _ready() -> void:
	was_ready_called = true


## called when entering tree
func start() -> void:
	# if called before ready, onready vars aren't set yet
	if was_ready_called:
		# in case the animation is still playing from before
		animation_player.stop(true)
		animation_player.play("spin")


## Checking collisions happens here because an enemy could stay in the hit box
## and continue to take damage (rather than using an on_entered signal)
func _physics_process(delta: float) -> void:
	handle_damage()
	handle_sprite_rotation(delta)


func handle_damage():
	# NOTE: if i add more buff sources it may make sense to put some of this
	# logic into a shared location
	var victim_areas = _get_potential_victims()
	for victim in victim_areas:
		_handle_victim(victim)


func _get_potential_victims() -> Array:
	var areas: Array = hit_box.get_overlapping_areas()

	var victims := []
	for area in areas:
		if area.has_method("get_unit"): # if it's a hurtbox
			victims.append(area.get_unit())

	return victims


## If the victim can take buffs and does not have the DamageCooldown buff for
## the sawblade, deal damage and apply the buff.
func _handle_victim(victim):
	if victim.has_method("get_buffs"):
		var buffs: Array = victim.get_buffs()
		for buff in buffs:
			if buff.get("source") == self:
				return

		# if we got here, we can deal damage
		var dc: DamageCooldown = damage_cooldown_scene.instance()
		dc.setup(self, damage_cooldown)
		victim.add_buff(dc)
		victim.take_damage(damage, owner)


func handle_sprite_rotation(delta):
	sprite.rotate(deg2rad(sprite_rotation_speed_deg * delta))
