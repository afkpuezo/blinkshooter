extends Node2D
class_name Gateway
## teleports the player to a specified target location
## configure it by adding a destination and optionally a lock


signal triggered() # should this have args?
signal fakeout_triggered() # used in the wave boss


# jank
enum TYPE {TELEPORT, LEVEL, FAKEOUT, GAME_END}
export(TYPE) var type = TYPE.TELEPORT

onready var sprite: Sprite = $Sprite
onready var label: Label = $CenterContainer/Label
onready var timer: Timer = $Timer

var destination: GatewayDestination

# these vars may be changed in ready
var num_locks_remaining := 0
var is_unlocked := false

# used when loading a level
export var level_scene_path: String

export var open_sprite: Texture
export var locked_sprite: Texture

export(PackedScene) var teleport_effect_scene
export var teleport_effect_scale_factor := 2.5
export var teleport_wait_time := 0.25
export var destination_teleport_effect_delay := 0.25

# avoids triggering multiple times while the player is hovering over the gateway
var is_working := false

# used in the wave boss
var has_fakeout_started := false


func _ready() -> void:
	for c in get_children():
		if c is GatewayDestination:
			destination = c

		if c is Lock:
			num_locks_remaining += 1
			c.connect("unlocked", self, "on_lock_unlock")
	# end for children
	if not destination and type == TYPE.TELEPORT:
		print("%s couldn't find a destination!" % name)

	update()


func on_unit_entered(unit: Unit):
	if type == TYPE.GAME_END:
		do_game_end(unit)
	else:
		if type == TYPE.FAKEOUT and not has_fakeout_started:
			do_fakeout()

		if is_unlocked:
			if is_working:
				pass
			else:
				is_working = true
				if type in [TYPE.LEVEL, TYPE.FAKEOUT]:
					move_to_next_level()
				else:
					teleport_unit(unit)
				# there will be a delay, so it makes sense to have this here
				is_working = false


func teleport_unit(unit: Unit):
	var is_player := PlayerBrain.is_player(unit)
	emit_signal("triggered")

	if teleport_effect_scene:
		var effect = teleport_effect_scene.instance()
		Spawner.spawn_node(effect, destination.global_position, 0, destination_teleport_effect_delay)
		effect.scale *= teleport_effect_scale_factor
	if is_player:
		GameEvents.emit_signal("player_teleport_started")

	timer.start(teleport_wait_time)
	yield(timer, "timeout")

	unit.global_position = destination.global_position

	if is_player:
		GameEvents.emit_signal("player_teleported")


func move_to_next_level():
	GameEvents.emit_signal("player_teleport_started")
	timer.start(teleport_wait_time)
	yield(timer, "timeout")
	LevelLoader.load_level(level_scene_path)


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


func do_fakeout():
	has_fakeout_started = true
	num_locks_remaining += 1
	emit_signal("fakeout_triggered")
	is_unlocked = false
	update()


func do_game_end(player: Unit):
	# just assume it's the player
	GameEvents.emit_signal("player_teleport_started")
	timer.start(teleport_wait_time)
	yield(timer, "timeout")
	emit_signal("triggered")
	GameEvents.emit_signal("game_won", {'player': player})
	player.queue_free()

