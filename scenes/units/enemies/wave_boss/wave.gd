extends Node2D
class_name Wave
## represents a single wave/group of enemies spawned during the 2nd boss fight


# can end when all the enemies are dead, or optionally when a timer has finished
signal unblocked()


onready var block_timer: Timer = $BlockTimer
export var use_block_timer := false
export var block_time := 0.0

var num_remaining_enemies := 0
var enemies := []
var current_enemy_index := 0
onready var delay_timer: Timer = $DelayTimer
export var delay_per_wave := 0.0


func _ready() -> void:
	pass


## called from outside
func trigger():
	pass


func spawn_next_enemy():
	pass


func _on_enemy_death():
	pass

