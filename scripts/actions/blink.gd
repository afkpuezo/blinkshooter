extends Action
class_name Blink
## Teleport the player towards the target reticle


export var max_range := 500
onready var max_range_squared := pow(max_range, 2)
export var min_range := 100
export var teleport_wait_time := 0.25
export(PackedScene) var effect_scene

# these are used to tell if the teleport location is clear
export(Shape2D) var teleport_buffer
var buffer_params := Physics2DShapeQueryParameters.new()
onready var physics_state := get_viewport().get_world_2d().direct_space_state

var cached_target_position = null

func _ready() -> void:
	buffer_params.set_shape(teleport_buffer)
	buffer_params.collision_layer = 0b111
	._ready()

# ----------
# virtual method(s) from Action
# ----------


## Steps:
## - if the target is too close, return false
## - if the target is too far, treat the farthest reachable point as the target
## - if the target area is clear, return true
func can_do_action() -> bool:
	var target_position = TargetReticle.get_true_global_position()

	if not _is_target_beyond_minimum_range(target_position):
		return false

	target_position = _cap_target_at_max_range(target_position)
	if _is_target_area_clear(target_position):
		cached_target_position = target_position
		return true
	else:
		return false


## Teleport at most max_range towards the target
func do_action():
	# NOTE: this cache idea might be unnecessary or even potentially bad, but
	# i'm leaving it for now
	var target_position = cached_target_position
	#var target_position
	#if cached_target_position:
	#	target_position = cached_target_position
	#else:
	#	target_position = TargetReticle.get_true_global_position()
	#	target_position = _cap_target_at_max_range(target_position)
	# now actually teleport
	if effect_scene:
		GameSpawner.spawn_node(effect_scene.instance(), user.get_position())
		GameSpawner.spawn_node(effect_scene.instance(), target_position)
	user.do_teleport_animation()
	yield(get_tree().create_timer(teleport_wait_time, false), "timeout")
	user.set_position(target_position) # should this be global position?



# ----------
# private/helper method(s)
# ----------


## does what it says
func _is_target_beyond_minimum_range(target_position: Vector2) -> bool:
	return user.position.distance_to(target_position) >= min_range


## does what it says
func _is_target_area_clear(target_position: Vector2) -> bool:
	buffer_params.transform = Transform2D(0, target_position)
	var intersected = physics_state.intersect_shape(buffer_params)
	return intersected.size() == 0


## if the given pos is outside of range, return a new position which is on the
## same line, but at max range. otherwise return the given target pos
func _cap_target_at_max_range(target_position: Vector2) -> Vector2:
	if user.position.distance_squared_to(target_position) > max_range_squared:
		var direction: Vector2 = \
			user.position.direction_to(target_position).normalized()
		return user.position + (direction * max_range)
	else:
		return target_position
