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
var play_duration: float

export var autoplay := false

var players := []
var timers := []
var current_index := 0


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
	# always
	play_duration = stop_time - start_time

	if autoplay:
		play()


## starts the sound effect on the next available stream player
## this one is called from signals
# arg for signals
func play(_arg = null, _arg1 = null):
	play_from_percent(0.0)


## starts the sound effect on the next available stream player,
## starting at the given time (as a percent of the time between
## the configured start time and stop time)
## if force_restart is false (default true) and the sound is already playing,
## the call will be ignored
## "percent" should actually be out of 1.0, eg half is 0.5
func play_from_percent(start_percent: float, force_restart := true):
	if players.empty() or ((not force_restart) and players[current_index].playing):
		return

	var temp_start := start_time + (play_duration * start_percent)
	var temp_duration = stop_time - temp_start

	players[current_index].play(temp_start)
	if stops_early:
		timers[current_index].start(temp_duration)

	current_index += 1
	if current_index >= players.size():
		current_index = 0


## stop playing the matching player when a timer ends
func on_timer_timeout(index: int):
	players[index].stop()


## avoids issue if stop time is after actual end of sound effect
func on_player_finished(index: int):
	timers[index].stop()


## stops ALL players and timers, which might be too much, but I suspect this
## method will only be called by the WeaponCharger, which only has one player
func stop():
	for p in players:
		p.stop()
	for t in timers:
		t.stop()
