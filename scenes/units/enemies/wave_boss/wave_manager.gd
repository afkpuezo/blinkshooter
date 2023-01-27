extends Node2D
class_name WaveManager
## spawns several waves of enemies when triggered, serving as a boss fight


signal defeated() # when all the waves have been defeated


onready var delay_timer: Timer = $DelayTimer
export var delay_between_each_wave := 0.0

var waves := []
var num_remaining_undefeated_waves := 0

export var always_detect_player := true
var player: Unit


func _ready() -> void:
	for c in get_children():
		if c is Wave:
			waves.append(c)
			c.connect("defeated", self, "_on_wave_defeated")
			num_remaining_undefeated_waves += 1

	if always_detect_player:
		# warning-ignore:return_value_discarded
		GameEvents.connect("player_spawned", self, "_on_player_spawn")
		# warning-ignore:return_value_discarded
		GameEvents.connect("player_died", self, "_on_player_death")


## called from outside
func trigger():
	var has_delay_between_each := delay_between_each_wave > 0.0
	for w in waves:
		w.trigger(player)
		yield(w, "unblocked")

		if has_delay_between_each:
			delay_timer.start(delay_between_each_wave)
			yield(delay_timer, "timeout")


func _on_wave_defeated():
	num_remaining_undefeated_waves -= 1
	if num_remaining_undefeated_waves <= 0:
		emit_signal("defeated")
		queue_free()


func _on_player_spawn(msg: Dictionary):
	print("WaveManager._on_player_spawn()")
	player = msg['player']


func _on_player_death(_msg: Dictionary):
	print("WaveManager._on_player_death()")
	player = null
