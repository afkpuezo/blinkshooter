extends Node2D
class_name AudioHelper
## so the audio in godot works a little dumber than I thought, this
## class should help with that
## handles:
## playing the same sound more than once (by cycling through multiple
## child players)
## - when to start/stop the playback (through export vars)


export var start_time := 0.0
export var stops_early := false
export var stop_time := 0.0
onready var play_duration := stop_time - start_time

var players := []
var timers := []
var current_player := 0


func _ready() -> void:
	for c in get_children():
		players.append(c)

	if stops_early:
		for index in players.size():
			var timer = Timer.new()
			timer.connect("timeout", self, "on_timer_timeout", [index])
			timers.append(timer)
			add_child(timer)
			players[index].connect("finished", self, "on_player_finished", [index])


## starts the sound effect on the next player
# arg for signals
func play(_arg = null):
	if players.empty():
		return

	players[current_player].play(start_time)
	if stops_early:
		timers[current_player].start(play_duration)

	current_player += 1
	if current_player >= players.size():
		current_player = 0


## stop playing the matching player when a timer ends
func on_timer_timeout(index: int):
	players[index].stop()


## avoids issue if stop time is after actual end of sound effect
func on_player_finished(index: int):
	timers[index].stop()
