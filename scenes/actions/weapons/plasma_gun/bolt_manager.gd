extends Node2D
class_name BoltManager
## creates some sprites that look like bolts of energy coming off of the plasma
## shot


export(Texture) var bolt_texture

export var min_num_bolts := 1
export var max_num_bolts := 3

export var min_rotation_speed_deg := 45
export var max_rotation_speed_deg := 180

var bolts_to_speed := {} # maps bolts to speed


func _ready() -> void:
	randomize()

	var num_bolts := ceil(rand_range(min_num_bolts - 1, max_num_bolts))
	print("num_bolts: %d" % num_bolts)

	for n in range(num_bolts):
		var bolt: Sprite = Sprite.new()
		bolt.texture = bolt_texture

		var speed := deg2rad(rand_range(min_rotation_speed_deg - 1, max_rotation_speed_deg))
		var polarity = 1 if randi() % 2 == 0 else -1
		speed *= polarity
		bolt.rotation = ((n + 1) / num_bolts) * 2 * PI # space them evenly

		bolts_to_speed[bolt] = speed
		add_child(bolt)


func _process(delta: float) -> void:
	for bolt in bolts_to_speed:
		bolt.rotate(bolts_to_speed[bolt] * delta)
