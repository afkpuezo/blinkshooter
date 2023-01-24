extends KinematicBody2D
#tool # this caused way too many headaches to be worth it
class_name Pickup
## holds an item for the player to pick up by walking over it


enum TYPE{
	NONE,
	SMALL_GUN, BIG_GUN, PLASMA_GUN, SHOTGUN, PHASE_RIFLE
	BLINK, SAWBLADE, SHURIKEN,
	HEALTH, BASIC_AMMO, PLASMA_AMMO, ENERGY
}
enum META_TYPE{
	WEAPON, ACTION, RESOURCE
}
enum SIZE{
	NORMAL, LARGE
}

export(TYPE) var type = TYPE.NONE
var item_scene: PackedScene
var meta_type: int

# these are only actually used for resource pickups
var resource_type: int # enum from CombatResource
var resource_amount: int
var size # only needed for resource pickups

## each type maps to a dict with:
##		matching scene path, texture path, radius, and meta type
## resource pickups also have resource_type, and a sub dict for each possible
## size, with resource_amount and scale_factor
# NOTE: this is probably putting too much stuff in this one script...
# NOTE: radius is applied BEFORE scaling
const TYPE_DETAILS = {
	TYPE.NONE: {
		'scene': "",
		'texture': "",
		'radius': 1,
		'meta_type': META_TYPE.ACTION,
	},
	# ----------
	# weapons start
	# ----------
	TYPE.SMALL_GUN: {
		'scene': "res://scenes/actions/weapons/small_gun/small_gun.tscn",
		'texture': "res://scenes/ui/player_ui/action_ui/assets/small_gun_tile.png",
		'radius': 64,
		'meta_type': META_TYPE.WEAPON,
	},
	TYPE.PLASMA_GUN: {
		'scene': "res://scenes/actions/weapons/plasma_gun/plasma_gun.tscn",
		'texture': "res://scenes/ui/player_ui/action_ui/assets/plasma_gun_tile.png",
		'radius': 64,
		'meta_type': META_TYPE.WEAPON,
	},
	TYPE.SHOTGUN: {
		'scene': "res://scenes/actions/weapons/shotgun/shotgun.tscn",
		'texture': "res://scenes/ui/player_ui/action_ui/assets/shotgun_tile.png",
		'radius': 64,
		'meta_type': META_TYPE.WEAPON,
	},
	TYPE.PHASE_RIFLE: {
		'scene': "res://scenes/actions/weapons/phase_rifle/phase_rifle.tscn",
		'texture': "res://scenes/ui/player_ui/action_ui/assets/phase_tile.png",
		'radius': 64,
		'meta_type': META_TYPE.WEAPON,
	},
	# ----------
	# actions start
	# ----------
	TYPE.BLINK: {
		'scene': "res://scenes/actions/blink/blink.tscn",
		'texture': "res://scenes/ui/player_ui/action_ui/assets/blink_tile.png",
		'radius': 64,
		'meta_type': META_TYPE.ACTION,
	},
	TYPE.SAWBLADE: {
		'scene': "res://scenes/actions/saw_blade/saw_blade.tscn",
		'texture': "res://scenes/ui/player_ui/action_ui/assets/sawblade_tile.png",
		'radius': 64,
		'meta_type': META_TYPE.ACTION,
	},
	TYPE.SHURIKEN: {
		'scene': "res://scenes/actions/shuriken/shuriken.tscn",
		'texture': "res://scenes/ui/player_ui/action_ui/assets/shuriken_tile.png",
		'radius': 64,
		'meta_type': META_TYPE.ACTION,
	},
	# ----------
	# resources start
	# ----------
	TYPE.HEALTH: {
		'scene': "",
		'texture': "res://scenes/pickups/resource_pickups/health_pickup.png",
		'radius': 8,
		'meta_type': META_TYPE.RESOURCE,
		'resource_type': CombatResource.Type.HEALTH,
		'size_normal': {
			'resource_amount': 20,
			'scale_factor': 1.0
		},
		'size_large': {
			'resource_amount': 50,
			'scale_factor': 2.0
		},
	},
	TYPE.ENERGY: {
		'scene': "",
		'texture': "res://scenes/pickups/resource_pickups/energy_pickup.png",
		'radius': 8,
		'meta_type': META_TYPE.RESOURCE,
		'resource_type': CombatResource.Type.ENERGY,
		'size_normal': {
			'resource_amount': 20,
			'scale_factor': 1.0
		},
		'size_large': {
			'resource_amount': 50,
			'scale_factor': 2.0
		},
	},
	TYPE.BASIC_AMMO: {
		'scene': "",
		'texture': "res://scenes/pickups/resource_pickups/bullet_pickup.png",
		'radius': 16,
		'meta_type': META_TYPE.RESOURCE,
		'resource_type': CombatResource.Type.BASIC_AMMO,
		'size_normal': {
			'resource_amount': 30,
			'scale_factor': 0.75
		},
		'size_large': {
			'resource_amount': 75,
			'scale_factor': 1.25
		},
	},
	TYPE.PLASMA_AMMO: {
		'scene': "",
		'texture': "res://scenes/pickups/resource_pickups/plasma_pickup.png",
		'radius': 16,
		'meta_type': META_TYPE.RESOURCE,
		'resource_type': CombatResource.Type.PLASMA_AMMO,
		'size_normal': {
			'resource_amount': 1,
			'scale_factor': 0.75
		},
		'size_large': {
			'resource_amount': 2,
			'scale_factor': 1.25
		},
	},
}

var done := false # used for freeing

# movemment vars
export var can_be_vacuumed := true
var is_being_vacuumed := false
var vacuum_position: Vector2
onready var pickup_mover: PickupMover = $PickupMover
onready var movement_stats: MovementStats = $MovementStats

# used for resource pickups to avoid bug with Tool
var needs_scaling = true
var resouce_scale_temp = 1


# ----------
# static funcs
# ----------


static func is_pickup(n):
	return n != null and n.has_method("get_item")


# ----------
# instance funcs
# ----------


## params are both enums
## size is only used for resource pickups
func configure(new_type: int, new_size: int = SIZE.NORMAL):
	type = new_type
	size = new_size
	var details = TYPE_DETAILS[type]

	if details['scene'] != "":
		item_scene = load(details['scene']) # better to load here or later?

	var shape := CircleShape2D.new()
	shape.radius = details['radius']
	$CollisionShape2D.shape = shape
	$Sprite.texture = load(details['texture'])
	meta_type = details['meta_type']

	if meta_type == META_TYPE.RESOURCE:
		_setup_resource_pickup(details)


## helper for set_type()
func _setup_resource_pickup(details: Dictionary):
	resource_type = details['resource_type']

	var size_str: String

	match size:
		SIZE.NORMAL:
			size_str = "size_normal"
		SIZE.LARGE:
			size_str = "size_large"

	var sub_details: Dictionary = details[size_str]
	resource_amount = sub_details['resource_amount']
	resouce_scale_temp = sub_details['scale_factor']


## only works if this pickup has an action or weapon. returns null if there is
## no scene because this is a resource pickup
## NOTE: that's probably a sign these belong in different classes
func get_item():
	done = true # wtb finally
	if item_scene:
		return item_scene.instance()
	else:
		return null


## returns an array with the two vars
## will be null, null if this is not a resource pickup
## the node will free itself after this is called
func get_resource_type_and_amount() -> Array:
	done = true
	return [resource_type, resource_amount]


## handles freeing and scaling for resouce pickups
func _process(_delta: float) -> void:
	if meta_type == META_TYPE.RESOURCE and needs_scaling:
		if not Engine.editor_hint:
			scale *= resouce_scale_temp
			needs_scaling = false

	if done:
		queue_free()


## handles movement
func _physics_process(_delta: float) -> void:
	if pickup_mover and can_be_vacuumed:
		if is_being_vacuumed:
				pickup_mover.be_vacuumed(self, movement_stats, vacuum_position)
		else:
			pickup_mover.idle(self, movement_stats)
		is_being_vacuumed = false # reset every frame


func set_vacuum_position(pos: Vector2):
	vacuum_position = pos
	is_being_vacuumed = true
