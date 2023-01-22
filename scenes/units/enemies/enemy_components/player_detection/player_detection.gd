extends Node2D
class_name PlayerDetection

# child nodes
onready var rays_node: Node2D = $RaysNode
var rays_arr: Array = []
var center_ray: RayCast2D # the one facing exactly forward
onready var area: Area2D = $Area2D

# export vars
export var detection_range := 256
onready var range_squared = pow(detection_range, 2)

## will round down to nearest odd number
## if the number is 1, it will always look straight ahead
export(int, 1, 9) var num_rays := 1
export(float, 0, 90) var max_ray_deg = 45.0
## the player is considered detected if this number of rays hit them
## capped at num_rays
export var num_ray_hits_required := 1

const CENTER_RAY_NAME = "CenterRay" # can't use == to identify i guess
 # if the center ray is in the enemy itself it will only see the enemy
export var center_ray_x_offset := 34

## configures components based on export vars
func _ready() -> void:
	if num_rays % 2 == 0:
		num_rays -= 1

	var rays_dict = _make_rays(num_rays, max_ray_deg)
	rays_arr =  rays_dict["all_rays"]
	center_ray = rays_dict["center_ray"]
	#print("DEBUG: PlayerDetection._ready(): how many rays?: %d" % rays_arr.size())
	for ray in rays_arr:
		rays_node.add_child(ray)
	num_ray_hits_required = int(min(num_ray_hits_required, num_rays))
	print("DEBUG: before updating, shape.radius is %d" % area.get_node("CollisionShape2D").shape.radius)
	area.get_node("CollisionShape2D").shape.radius = detection_range
	print("DEBUG: detection_range is %d, shape.radius is %d" % [detection_range, area.get_node("CollisionShape2D").shape.radius])


## creates the configured number of rays spready evenly within the configured
## angle
## finds the ray that faces forward at 0 degrees
## returns a dict with 'all_rays' and 'center_ray'
func _make_rays(nr: int, mrd: float) -> Dictionary:
	var rs := []
	var step_per_ray
	var start_angle
	var c_r

	if nr > 1:
		step_per_ray = deg2rad((mrd * 2) / (nr - 1)) * -1
		start_angle = deg2rad(mrd)
	else:
		step_per_ray = 0
		start_angle = 0

	for n in range(0, nr):
		var ray: RayCast2D = RayCast2D.new()
		ray.cast_to = Vector2(detection_range, 0)
		var ray_rads = start_angle + (step_per_ray * n)
		#print("DEBUG: PlayerDetection._ready(): creating ray #%d with rotation %f" % [n, rad2deg(ray_rads)])
		ray.rotate(ray_rads)
		if ray_rads == 0:
			c_r = ray
			c_r.name = CENTER_RAY_NAME
			ray.collision_mask = 0b111 # enemy, wall, and player
			ray.position.x = center_ray_x_offset
		else:
			ray.collision_mask = 0b11 # wall and player
		ray.exclude_parent = true
		ray.enabled = true
		rs.append(ray)

	return {
		"all_rays": rs,
		"center_ray": c_r
	}


## Returns a dictionary with the following fields:
## is_player_detected -> bool
## player -> Player node if found, or null
## is_detected_by_center -> bool if found by the center ray (at 0 degrees)
func check() -> Dictionary:
	# convoluted
	var return_dict := {
		'is_player_detected': false,
		'player': null,
		'is_detected_by_center': false,
	}

	# first check if the player is close enough
	var bodies = area.get_overlapping_bodies()
	if bodies.empty():
		return return_dict

	var player: Unit
	for body in bodies:
		if PlayerBrain.is_player(body):
			player = body
			break

	# now try raycast
	#rays_node.look_at(player.position)

	var num_hits = 0
	for ray in rays_arr:
		#print("DEBUG: PlayerDetection._ready(): checking ray")
		ray.force_raycast_update()
		if ray.is_colliding() and PlayerBrain.is_player(ray.get_collider()):
			num_hits += 1
			#if ray == center_ray:
			if ray.name == CENTER_RAY_NAME:
				#print("DEBUG: ray.name is CenterRay")
				return_dict["is_detected_by_center"] = true

	if num_hits >= num_ray_hits_required:
		return_dict["is_player_detected"] = true
		return_dict["player"] = player
		return return_dict
	else:
		return return_dict


## is this redundant?
func is_player_detected() -> bool:
	return check()["is_player_detected"]

