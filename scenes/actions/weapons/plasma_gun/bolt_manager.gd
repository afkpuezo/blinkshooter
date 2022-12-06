extends Node2D
class_name BoltManager
## creates some sprites that look like bolts of energy coming off of the plasma
## shot


export(Texture) var bolt_texture

export var min_num_bolts := 1
export var max_num_bolts := 3

export var min_flicker_time := 0.2
export var max_flicker_time := 0.5

var timers_to_bolts := {}


func _ready() -> void:
	randomize()

	rotate(rand_range(0, 2 * PI))

	var num_bolts := ceil(rand_range(min_num_bolts - 1, max_num_bolts))

	for n in range(num_bolts):
		var bolt: Sprite = Sprite.new()
		bolt.texture = bolt_texture
		bolt.rotation = ((n + 1) / num_bolts) * 2 * PI # space them evenly
		add_child(bolt)

		var timer = Timer.new()
		timers_to_bolts[timer] = bolt
		timer.one_shot = true
		add_child(timer)

		timer.connect("timeout", self, "on_timer_timeout", [timer])
		timer.start(get_random_time())


func on_timer_timeout(timer: Timer):
	var bolt: Sprite = timers_to_bolts[timer]
	bolt.visible = not bolt.visible
	timer.start(get_random_time())


func get_random_time() -> float:
	return rand_range(min_flicker_time, max_flicker_time)
