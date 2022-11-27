extends Area2D
class_name Pickup
## holds an item for the player to pick up by walking over it


enum TYPE{SMALL_GUN, BIG_GUN, BLINK, SAWBLADE, SHURIKEN, HEALTH, BASIC_AMMO, BIG_AMMO}
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
		'texture': "res://scenes/ui/player_ui/action_ui/assets/small_gun_item_oj.png",
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
		'texture': "res://scenes/ui/player_ui/action_ui/assets/blink_item.png",
		'radius': 64,
		'meta_type': META_TYPE.ACTION,
	},
	TYPE.SAWBLADE: {
		'scene': "res://scenes/actions/saw_blade/saw_blade.tscn",
		'texture': "res://scenes/ui/player_ui/action_ui/assets/sawblade_item.png",
		'radius': 64,
		'meta_type': META_TYPE.ACTION,
	},
	TYPE.SHURIKEN: {
		'scene': "res://scenes/actions/shuriken/shuriken.tscn",
		'texture': "res://scenes/ui/player_ui/action_ui/assets/shuriken_item.png",
		'radius': 64,
		'meta_type': META_TYPE.ACTION,
	},
	TYPE.HEALTH: {
		'scene': "",
		'texture': "",
		'radius': 32,
		'meta_type': META_TYPE.RESOURCE,
		'resource_type': CombatResource.Type.HEALTH,
		'resource_amount': 10
	},
	TYPE.BASIC_AMMO: {
		'scene': "",
		'texture': "",
		'radius': 32,
		'meta_type': META_TYPE.RESOURCE,
		'resource_type': CombatResource.Type.BASIC_AMMO,
		'resource_amount': 20
	},
	TYPE.BIG_AMMO: {
		'scene': "",
		'texture': "",
		'radius': 32,
		'meta_type': META_TYPE.RESOURCE,
		'resource_type': CombatResource.Type.BIG_AMMO,
		'resource_amount': 20
	},
}

var done := false


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

	item_scene = load(details['scene']) # better to load here or later?
	$CollisionShape2D.shape.radius = details['radius']
	$Sprite.texture = load(details['texture'])
	meta_type = details['meta_type']


func get_item():
	done = true # wtb finally
	return item_scene.instance()


func _process(_delta: float) -> void:
	if done:
		queue_free()
