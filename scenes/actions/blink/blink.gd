extends Action
class_name Blink
## Teleport the player towards the target reticle
## NOTE: i'm keeping all of the old buffer param based code commented in case
## i need to go back to it


# child node vars
onready var raycast: RayCast2D = $RayCast2D

export var max_range := 500
export var min_range := 100
export var raycast_offset := 16
export var teleport_wait_time := 0.25
export var destination_teleport_effect_delay := 0.1
export(PackedScene) var effect_scene

# faster calcs for distance squared
onready var max_range_squared := pow(max_range, 2)
onready var min_squared = pow(min_range, 2)

var cached_target_position = null


# ----------
# virtual method(s) from Action
# ----------


## returns true/false if the target destination position is valid
## - starts at the ray position
## - if that is too close, return false
## - cast back towards the user's position until floor is found
## - if there is a found location and it is not too close to the user's current
##		position, return true. otherwise, return false
func can_do_action() -> bool:
	var target_position = raycast.global_position

	if not _is_target_beyond_minimum_range(target_position):
		return false

	target_position = _find_nearest_floor()

	if not _is_target_beyond_minimum_range(target_position):
		return false

	cached_target_position = target_position
	return true


## Teleport at most max_range towards the target
func do_action():
	var target_position = cached_target_position

	var destination_effect
	if effect_scene:
		Spawner.spawn_node(effect_scene.instance(), user.get_position())
		destination_effect = effect_scene.instance()
		Spawner.spawn_node(destination_effect, target_position, 0, destination_teleport_effect_delay)
	GameEvents.emit_signal("player_teleport_started")

	yield(get_tree().create_timer(teleport_wait_time, false), "timeout")
	GameEvents.emit_signal("player_teleported")
	user.global_position = target_position

	if destination_effect:
		# moving the effect position looks better if the player gets pushed away
		# by a wall after blinking
		yield(get_tree().create_timer(0.05, false), "timeout")
		destination_effect.position = user.get_position()


# ----------
# private/helper method(s)
# ----------


## regularly update the position of the raycast, starting at the mouse position
## and clamping it to the maximum range
func _physics_process(_delta: float) -> void:
	var raypos = TargetReticle.get_true_global_position()
	raypos = _cap_target_at_max_range(raypos)
	raycast.global_position = raypos
	raycast.cast_to = raycast.to_local(global_position)


## does what it says
func _is_target_beyond_minimum_range(target_position: Vector2) -> bool:
	return global_position.distance_squared_to(target_position) >= min_squared


## cast from the (recent) ray position towards the user, find the nearest
## floor tile
func _find_nearest_floor() -> Vector2:
	return raycast.get_collision_point()


## if the given pos is outside of range, return a new position which is on the
## same line, but at max range. otherwise return the given target pos
func _cap_target_at_max_range(target_position: Vector2) -> Vector2:
	if user.global_position.distance_squared_to(target_position) > max_range_squared:
		var direction: Vector2 = \
			user.global_position.direction_to(target_position).normalized()
		return user.global_position + (direction * max_range)
	else:
		return target_position
