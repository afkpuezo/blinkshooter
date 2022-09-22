extends Action
class_name Blink
## Teleport the player towards the target reticle


export var MAX_RANGE := 500
export var MIN_RANGE := 100
export var TELEPORT_WAIT_TIME := 0.25
export(PackedScene) var effect_scene

# these are used to tell if the teleport location is clear
export(Shape2D) var teleport_buffer
var buffer_params := Physics2DShapeQueryParameters.new()
onready var physics_state := get_viewport().get_world_2d().direct_space_state

func _ready() -> void:
	buffer_params.set_shape(teleport_buffer)
	buffer_params.collision_layer = 0b111
	._ready()

# ----------
# virtual method(s) from Action
# ----------


func can_do_action() -> bool:
	var target_position = TargetReticle.get_true_global_position()
	return self._is_target_beyond_minimum_range(target_position) and self._is_target_area_clear(target_position)


## Teleport at most MAX_RANGE towards the target
func do_action():
	var target_position = TargetReticle.get_true_global_position()
	var distance = user.position.distance_to(target_position)
	#if distance < MIN_RANGE: # covered in can_do_action()
		#return # TODO: explain why it failed?
	if distance > MAX_RANGE:
		# go as far as we can
		var direction: Vector2 = \
				user.position.direction_to(target_position).normalized()
		target_position = user.position + (direction * MAX_RANGE)
	# now actually teleport
	if effect_scene:
		GameSpawner.spawn_node(effect_scene.instance(), user.get_position())
		GameSpawner.spawn_node(effect_scene.instance(), target_position)
	user.do_teleport_animation()
	yield(get_tree().create_timer(TELEPORT_WAIT_TIME, false), "timeout")
	user.set_position(target_position) # should this be global position?

# ----------
# private/helper method(s)
# ----------

## does what it says
func _is_target_beyond_minimum_range(target_position: Vector2) -> bool:
	return user.position.distance_to(target_position) >= MIN_RANGE

## does what it says
func _is_target_area_clear(target_position: Vector2) -> bool:
	buffer_params.transform = Transform2D(0, target_position)
	var intersected = physics_state.intersect_shape(buffer_params)
	return intersected.size() == 0
