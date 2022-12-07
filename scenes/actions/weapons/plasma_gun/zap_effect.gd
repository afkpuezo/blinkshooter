extends Node2D
class_name ZapEffect
## creates some sprites that look like bolts of energy coming off of the plasma
## shot


export(Texture) var bolt_texture

export var min_num_bolts := 1
export var max_num_bolts := 3

export var min_flicker_time := 0.2
export var max_flicker_time := 0.5

export var flip_time := 0.12

var flicker_timers_to_bolts := {}
var flip_timers_to_bolts := {}

export var duration := 0 ## if 0, no time limit
onready var life_timer: Timer = $LifeTimer


# ----------
# setup
# ----------

func _ready() -> void:
	randomize()

	if duration != 0:
		life_timer.start(duration)

	rotate(rand_range(0, 2 * PI))

	var num_bolts := ceil(rand_range(min_num_bolts - 1, max_num_bolts))

	for n in range(num_bolts):
		var bolt: Sprite = Sprite.new()
		bolt.texture = bolt_texture
		bolt.rotation = ((n + 1) / num_bolts) * 2 * PI # space them evenly
		add_child(bolt)
		setup_flicker_timer(bolt)
		setup_flip_timer(bolt)


func setup_flicker_timer(bolt: Sprite):
	var timer = Timer.new()
	flicker_timers_to_bolts[timer] = bolt
	timer.one_shot = true
	add_child(timer)

	timer.connect("timeout", self, "handle_flicker", [timer])
	timer.start(get_random_flicker_time())


func setup_flip_timer(bolt: Sprite):
	var timer = Timer.new()
	flip_timers_to_bolts[timer] = bolt
	timer.one_shot = true
	add_child(timer)

	timer.connect("timeout", self, "handle_flip", [timer])
	timer.start(flip_time)


func get_random_flicker_time() -> float:
	return rand_range(min_flicker_time, max_flicker_time)


# ----------
# running
# ----------


func handle_life_timer():
	queue_free()


func handle_flicker(timer: Timer):
	var bolt: Sprite = flicker_timers_to_bolts[timer]
	bolt.visible = not bolt.visible
	timer.start(get_random_flicker_time())


func handle_flip(timer: Timer):
	var bolt: Sprite = flip_timers_to_bolts[timer]
	bolt.scale.x *= -1
	timer.start(flip_time)
