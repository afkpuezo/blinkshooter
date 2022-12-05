extends Area2D
class_name Pickup
## holds an item for the player to pick up by walking over it


enum TYPE{
	SMALL_GUN, BIG_GUN,
	BLINK, SAWBLADE, SHURIKEN,
	HEALTH, BASIC_AMMO, BIG_AMMO, ENERGY
}
enum META_TYPE{WEAPON, ACTION, RESOURCE}
export(TYPE) var type
var item_scene: PackedScene
var meta_type: int

# these are only actually used for resource pickups
var resource_type: int # enum from CombatResource
var resource_amount: int

## each type maps to a dict with:
##		matching scene path, texture path, radius, and meta type
## resource pickups also have resource_type, resource_amount
# NOTE: this is probably putting too much stuff in this one script...
const TYPE_DETAILS = {
	TYPE.SMALL_GUN: {
		'scene': "res://scenes/actions/weapons/small_gun/small_gun.tscn",
		'texture': "res://scenes/ui/player_ui/action_ui/assets/small_gun_tile.png",
		'radius': 64,
		'meta_type': META_TYPE.WEAPON,
	},
	TYPE.BIG_GUN: {
		'scene': "res://scenes/actions/weapons/big_gun/big_gun.tscn",
		'texture': "res://scenes/ui/player_ui/action_ui/assets/big_gun_item_oj.png",
		'radius': 64,
		'meta_type': META_TYPE.WEAPON,
	},
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
	TYPE.HEALTH: {
		'scene': "",
		'texture': "res://scenes/pickups/hp_pickups/hp_pickup.png",
		'radius': 32,
		'meta_type': META_TYPE.RESOURCE,
		'resource_type': CombatResource.Type.HEALTH,
		'resource_amount': 20
	},
	TYPE.ENERGY: {
		'scene': "",
		'texture': "res://scenes/pickups/hp_pickups/energy_pickup.png",
		'radius': 32,
		'meta_type': META_TYPE.RESOURCE,
		'resource_type': CombatResource.Type.ENERGY,
		'resource_amount': 50
	},
	TYPE.BASIC_AMMO: {
		'scene': "",
		'texture': "res://scenes/pickups/hp_pickups/small_ammo_pickup.png",
		'radius': 32,
		'meta_type': META_TYPE.RESOURCE,
		'resource_type': CombatResource.Type.BASIC_AMMO,
		'resource_amount': 30
	},
	TYPE.BIG_AMMO: {
		'scene': "",
		'texture': "res://scenes/pickups/hp_pickups/big_ammo_pickup.png",
		'radius': 32,
		'meta_type': META_TYPE.RESOURCE,
		'resource_type': CombatResource.Type.BIG_AMMO,
		'resource_amount': 1
	},
}

var done := false # used for freeing

# movemment vars
export var can_be_vacuumed := true
var is_being_vacuumed := false
var vacuum_position: Vector2
onready var pickup_mover: PickupMover = $PickupMover
onready var movement_stats: MovementStats = $MovementStats


# ----------
# static funcs
# ----------


static func is_pickup(n):
	return n != null and n.has_method("get_item")


# ----------
# instance funcs
# ----------


func _ready() -> void:
	var details = TYPE_DETAILS[type]

	if details['scene'] != "":
		item_scene = load(details['scene']) # better to load here or later?
	$CollisionShape2D.shape.radius = details['radius']
	$Sprite.texture = load(details['texture'])
	meta_type = details['meta_type']

	if meta_type == META_TYPE.RESOURCE:
		resource_type = details['resource_type']
		resource_amount = details['resource_amount']


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


## handles freeing
func _process(_delta: float) -> void:
	if done:
		queue_free()


## handles movement
func _physics_process(_delta: float) -> void:
	if can_be_vacuumed:
		if is_being_vacuumed:
				pickup_mover.be_vacuumed(self, movement_stats, vacuum_position)
		else:
			pickup_mover.idle(self, movement_stats)
		is_being_vacuumed = false # reset every frame


func set_vacuum_position(pos: Vector2):
	vacuum_position = pos
	is_being_vacuumed = true
