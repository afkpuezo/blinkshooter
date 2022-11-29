extends Action
class_name Blink
## Teleport the player towards the target reticle
## NOTE: i'm keeping all of the old buffer param based code commented in case
## i need to go back to it


# child node vars
onready var raycast: RayCast2D = $RayCast2D

export var max_range := 500
export var min_range := 100
export var teleport_wait_time := 0.25
export(PackedScene) var effect_scene

# faster calcs for distance squared
onready var max_range_squared := pow(max_range, 2)
onready var min_squared = pow(min_range, 2)

# these are used to tell if the teleport location is clear (and floor)
#export(Shape2D) var teleport_buffer
#var wall_buffer_params := Physics2DShapeQueryParameters.new()
#var floor_buffer_params := Physics2DShapeQueryParameters.new()
#onready var physics_state := get_viewport().get_world_2d().direct_space_state

var cached_target_position = null

func _ready() -> void:
	# set up buffer params for physics stuff
	#wall_buffer_params.set_shape(teleport_buffer)
	#wall_buffer_params.collision_layer = 0b1 # Wall, Enemy
	#floor_buffer_params.set_shape(teleport_buffer)
	#floor_buffer_params.collision_layer = 0b10000 # floor layer
	# configure raycast
	raycast.cast_to = Vector2(max_range, 0)
	raycast.force_raycast_update()
	._ready()


# ----------
# virtual method(s) from Action
# ----------


## returns true/false if the target destination position is valid
## - starts at the cursor position
## - if that is too far away, clamp it to max range
## - cast back towards the user's position until floor is found
## - if there is a found location and it is not too close to the user's current
##		position, return true. otherwise, return false
func can_do_action() -> bool:
	var target_position = TargetReticle.get_true_global_position()

	target_position = _cap_target_at_max_range(target_position)
	target_position = _find_nearest_floor(target_position)

	if not _is_target_beyond_minimum_range(target_position):
		return false

	if target_position:
		cached_target_position = target_position
		return true
	else:
		return false


## Teleport at most max_range towards the target
func do_action():
	# NOTE: this cache idea might be unnecessary or even potentially bad, but
	# i'm leaving it for now
	var target_position = cached_target_position

	var destination_effect
	if effect_scene:
		Spawner.spawn_node(effect_scene.instance(), user.get_position())
		destination_effect = effect_scene.instance()
		Spawner.spawn_node(destination_effect, target_position, 0, 0.1)
	user.do_teleport_animation()

	yield(get_tree().create_timer(teleport_wait_time, false), "timeout")
	GameEvents.emit_signal("player_teleported")
	user.set_position(target_position) # should this be global position?

	if destination_effect:
		yield(get_tree().create_timer(0.05, false), "timeout")
		destination_effect.position = user.get_position()


# ----------
# private/helper method(s)
# ----------


## does what it says
func _is_target_beyond_minimum_range(target_position: Vector2) -> bool:
	return global_position.distance_squared_to(target_position) >= min_squared


## does what it says
#func _is_target_area_floor(target_position: Vector2) -> bool:
#	floor_buffer_params.transform = Transform2D(0, target_position)
#	var intersected = physics_state.intersect_shape(floor_buffer_params)
#	return not intersected.empty()


## does what it says
#func _is_target_area_clear(target_position: Vector2) -> bool:
#	wall_buffer_params.transform = Transform2D(0, target_position)
#	var intersected = physics_state.intersect_shape(wall_buffer_params)
#	return intersected.empty()


## starting from the given point and casting towards the current location of the
## user, find the closest floor space we can blink to.
## if no space is found, return null
func _find_nearest_floor(target_position: Vector2):
	# place and angle ray
	raycast.global_position = target_position
	raycast.look_at(global_position)
	raycast.force_raycast_update()

	return raycast.get_collision_point()


## if the given pos is outside of range, return a new position which is on the
## same line, but at max range. otherwise return the given target pos
func _cap_target_at_max_range(target_position: Vector2) -> Vector2:
	if user.position.distance_squared_to(target_position) > max_range_squared:
		var direction: Vector2 = \
			user.position.direction_to(target_position).normalized()
		return user.position + (direction * max_range)
	else:
		return target_position
