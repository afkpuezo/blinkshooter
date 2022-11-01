extends Node2D
class_name PlayerDetection

# child nodes
onready var rays_node: Node2D = $RaysNode
var rays_arr: Array = []
onready var area: Area2D = $Area2D

# export vars
export var detection_range := 256
onready var range_squared = pow(detection_range, 2)

## if this number isn't odd, there won't be one looking straight ahead!
## if the number is 1, it will always look straight ahead
export(int, 1, 9) var num_rays := 1
export(float, 0, 90) var max_ray_deg = 45.0
## the player is considered detected if this number of rays hit them
## capped at num_rays
export var num_ray_hits_required := 1


## configures components based on export vars
func _ready() -> void:
	rays_arr = _make_rays(num_rays, max_ray_deg)
	#print("DEBUG: PlayerDetection._ready(): how many rays?: %d" % rays_arr.size())
	for ray in rays_arr:
		rays_node.add_child(ray)
	num_ray_hits_required = int(min(num_ray_hits_required, num_rays))
	area.get_node("CollisionShape2D").shape.radius = detection_range


## creates the configured number of rays spready evenly within the configured
## angle
func _make_rays(nr: int, mrd: float) -> Array:
	var rs := []
	var step_per_ray
	var start_angle

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
		ray.enabled = true
		ray.collision_mask = 0b11 # wall and player
		rs.append(ray)

	return rs


## Returns null if the player is not currently detected
func get_player_if_detected() -> Player:
	# first check if the player is close enough
	var bodies = area.get_overlapping_bodies()
	if bodies.empty():
		return null

	var player: Player
	for body in bodies:
		if body is Player:
			player = body
			break

	# now try raycast
	rays_node.look_at(player.position)

	var num_hits = 0
	for ray in rays_arr:
		#print("DEBUG: PlayerDetection._ready(): checking ray")
		ray.force_raycast_update()
		if ray.is_colliding() and ray.get_collider() is Player:
			num_hits += 1

	if num_hits >= num_ray_hits_required:
		return player
	else:
		return null


## is this redundant?
func is_player_detected() -> bool:
	return get_player_if_detected() != null

