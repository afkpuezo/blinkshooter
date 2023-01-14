extends Node2D
class_name Gateway
## teleports the player to a specified target location
## configure it by adding a destination and optionally a lock


signal triggered() # should this have args?


onready var sprite: Sprite = $Sprite
onready var label: Label = $CenterContainer/Label

var destination: GatewayDestination

# these vars may be changed in ready
var num_locks_remaining := 0
var is_unlocked := false

export var load_level := false
export var level_name: String

export var open_sprite: Texture
export var locked_sprite: Texture

export(PackedScene) var teleport_effect_scene
export var teleport_effect_scale_factor := 2.5
export var teleport_wait_time := 0.25
export var destination_teleport_effect_delay := 0.25


func _ready() -> void:
	for c in get_children():
		if c is GatewayDestination:
			destination = c

		if c is Lock:
			num_locks_remaining += 1
			c.connect("unlocked", self, "on_lock_unlock")
	# end for children
	if not destination and not load_level:
		print("%s couldn't find a destination!" % name)

	update()


func on_unit_entered(unit: Unit):
	if is_unlocked:
		if load_level:
			LevelLoader.load_level(level_name)
		else:
			teleport_unit(unit)


func teleport_unit(unit: Unit):
	var is_player := PlayerBrain.is_player(unit)
	emit_signal("triggered")

	if teleport_effect_scene:
		var effect = teleport_effect_scene.instance()
		Spawner.spawn_node(effect, destination.global_position, 0, destination_teleport_effect_delay)
		effect.scale *= teleport_effect_scale_factor
	if is_player:
		GameEvents.emit_signal("player_teleport_started")

	yield(get_tree().create_timer(teleport_wait_time, false), "timeout")

	unit.global_position = destination.global_position

	if is_player:
		GameEvents.emit_signal("player_teleported")


func on_lock_unlock():
	num_locks_remaining -= 1
	update()


## handles lock state and sprite
func update():
	label.text = String(num_locks_remaining)
	if num_locks_remaining <= 0:
		is_unlocked = true
		label.visible = false
	else:
		label.visible = true

	if is_unlocked:
		sprite.texture = open_sprite
	else:
		sprite.texture = locked_sprite
