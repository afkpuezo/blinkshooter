extends Node2D
class_name WaveManager
## spawns several waves of enemies when triggered, serving as a boss fight


signal defeated() # when all the waves have been defeated


onready var delay_timer: Timer = $DelayTimer
export var delay_between_each_wave := 0.0

var waves := []
var num_remaining_undefeated_waves := 0


func _ready() -> void:
	for c in get_children():
		if c is Wave:
			waves.append(c)
			c.connect("defeated", self, "_on_wave_defeated")
			num_remaining_undefeated_waves += 1


## called from outside
func trigger():
	var has_delay_between_each := delay_between_each_wave > 0.0
	for w in waves:
		w.trigger()
		yield(w, "unblocked")

		if has_delay_between_each:
			delay_timer.start(delay_between_each_wave)
			yield(delay_timer, "timeout")


func _on_wave_defeated():
	num_remaining_undefeated_waves -= 1
	if num_remaining_undefeated_waves <= 0:
		emit_signal("defeated")
		queue_free()
