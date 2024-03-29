extends Node2D
class_name Wave
## represents a single wave/group of enemies spawned during the 2nd boss fight


# called when the next wave can start, either timer or all enemies defeated
signal unblocked()
# only called when all enemies are defeated
signal defeated()

var is_blocked := true

onready var block_timer: Timer = $BlockTimer
export var use_block_timer := false
export var block_time := 0.0

var num_remaining_enemies := 0
var wave_enemies := []
onready var delay_timer: Timer = $DelayTimer # redundant?
export var delay_between_each_enemy := 0.0


func _ready() -> void:
	for c in get_children():
		if c is WaveEnemy:
			wave_enemies.append(c)
			num_remaining_enemies += 1
			c.connect("died", self, "_on_enemy_death")


## called from outside
# janky to pass reference to the wave manager, but passing a reference to the
# player can cause a crash if the player is freed
# can't refer to the WaveManager class directly cuz dumb
func trigger(wave_manager):
	# should this be called AFTER all of the enemies are spawned?
	if use_block_timer and block_time > 0.0:
		block_timer.start(block_time)

	# idk if it's better to yield to a timer each loop or keep a cumulative_delay
	var delay_each := delay_between_each_enemy > 0.0
	for w in wave_enemies:
		w.trigger(wave_manager)
		if delay_each:
			delay_timer.start(delay_between_each_enemy)
			yield(delay_timer, "timeout")


func _on_enemy_death():
	num_remaining_enemies -= 1
	if num_remaining_enemies <= 0:
		_unblock()
		emit_signal("defeated")
		queue_free() # only delete once all the enemies are dead, not on timer


func _on_block_timer_timeout():
	_unblock()


func _unblock():
	if is_blocked:
		is_blocked = false
		emit_signal("unblocked")

