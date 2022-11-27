extends Area2D
class_name Pickup
## holds an item for the player to pick up by walking over it


enum PICKUP_TYPE{small_gun, big_gun, blink, sawblade, shuriken, hp, small_ammo, big_ammo}
export(PICKUP_TYPE) var type
var item_scene

# each type maps to a dict with the matching scene path, texture path, and radius
const TYPE_DETAILS = {
	PICKUP_TYPE.small_gun: {
		'scene': "res://scenes/actions/weapons/small_gun/small_gun.tscn",
		'texture': "res://scenes/ui/player_ui/action_ui/assets/small_gun_item_oj.png",
		'radius': 64,
	},
	PICKUP_TYPE.big_gun: {
		'scene': "res://scenes/actions/weapons/big_gun/big_gun.tscn",
		'texture': "res://scenes/ui/player_ui/action_ui/assets/big_gun_item_oj.png",
		'radius': 64,
	},
	PICKUP_TYPE.blink: {
		'scene': "res://scenes/actions/blink/blink.tscn",
		'texture': "res://scenes/ui/player_ui/action_ui/assets/blink_item.png",
		'radius': 64,
	},
	PICKUP_TYPE.sawblade: {
		'scene': "res://scenes/actions/saw_blade/saw_blade.tscn",
		'texture': "res://scenes/ui/player_ui/action_ui/assets/sawblade_item.png",
		'radius': 64,
	},
	PICKUP_TYPE.shuriken: {
		'scene': "res://scenes/actions/shuriken/shuriken.tscn",
		'texture': "res://scenes/ui/player_ui/action_ui/assets/shuriken_item.png",
		'radius': 64,
	},
	PICKUP_TYPE.hp: {
		'scene': "",
		'texture': "",
		'radius': 32,
	},
	PICKUP_TYPE.small_ammo: {
		'scene': "",
		'texture': "",
		'radius': 32,
	},
	PICKUP_TYPE.big_ammo: {
		'scene': "",
		'texture': "",
		'radius': 32,
	},
}

export var radius := 32

var done := false


func _ready() -> void:
	var details = TYPE_DETAILS[type]

	item_scene = load(details['scene']) # better to load here or later?
	$CollisionShape2D.shape.radius = details['radius']
	$Sprite.texture = load(details['texture'])


func get_item():
	done = true # wtb finally
	return item_scene.instance()


func _process(_delta: float) -> void:
	if done:
		queue_free()
