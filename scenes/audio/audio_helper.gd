extends Node2D
class_name AudioHelper
## so the audio in godot works a little dumber than I thought, this
## class should help with that
## handles:
## playing the same sound more than once (by cycling through multiple
## child players)
## - when to start/stop the playback (through export vars)


export var start_time := 0.0
# if no stop time, use stream's length
export var stops_early := false
export var stop_time := 0.0
onready var play_duration := stop_time - start_time

var players := []
var timers := []
var current_player := 0


func _ready() -> void:
	var index = 0
	for c in get_children():
		players.append(c)

		if stops_early:
			var timer = Timer.new()
			timer.connect("timeout", self, "on_timer_timeout", [index])
			timers.append(timer)
			add_child(timer)
			c.connect("finished", self, "on_player_finished", [index])

		index += 1
	# end for c

	# if we need to get the default stop_time
	if not stops_early and not players.empty():
		stop_time = players[0].stream.get_length()
		play_duration = stop_time - start_time


## starts the sound effect on the next available stream player
## this one is called from signals
# arg for signals
func play(_arg = null):
	play_from_percent(0.0)


## starts the sound effect on the next available stream player,
## starting at the given time (as a percent of the time between
## the configured start time and stop time)
## "percent" should actually be out of 1.0, eg half is 0.5
func play_from_percent(start_percent: float):
	if players.empty():
		return

	var temp_duration := start_time + (play_duration * start_percent)

	players[current_player].play(temp_duration)
	if stops_early:
		timers[current_player].start(temp_duration)

	current_player += 1
	if current_player >= players.size():
		current_player = 0


## stop playing the matching player when a timer ends
func on_timer_timeout(index: int):
	players[index].stop()


## avoids issue if stop time is after actual end of sound effect
func on_player_finished(index: int):
	timers[index].stop()
