extends Node2D
class_name EnemyMessager
## When one enemy detects the player, it tells nearby enemies about it using this


signal received_message(msg)


## other enemies whose receivers are inside our sender can hear our messages
export var sender_radius := 128
export var receiver_radius := 32
const RAY_OFFSET := 1 # LOSRay is placed this far past the receiver radius


# refs to nodes
onready var sender: Area2D = $Sender
onready var receiver: Area2D = $Receiver
# rotate the pivot to keep the ray at a fixed radius
onready var los_ray: RayCast2D = $Receiver/LOSRay

# debug
var effect_scene = load("res://scenes/effects/teleport_effect.tscn")


func _ready() -> void:
	los_ray.force_raycast_update()
	#los_ray.force_update_transform()
	# set size of areas
	sender.get_node("CollisionShape2D").shape.radius = sender_radius
	receiver.get_node("CollisionShape2D").shape.radius = receiver_radius


## only sends messages to other enemies whose receiving areas are within our
## sender_radius AND in line-of-sight
func send_message(msg):
	#print("DEBUG: EnemyMessager.send_message() called")
	for area in sender.get_overlapping_areas():
		# don't send a message to ourself
		if area == receiver:
			continue

		if area.has_method("receive_message"):
			if _check_los(area):
				area.receive_message(msg)
			else:
				#print("DEBUG: EnemyMessager.send_message() check_los() call failed")
				pass
		else:
			print("WARN: EnemyMessager.send_message() found overlapping area that doesn't have receive_message(): %s " % area.name)


func receive_message(msg):
	#print("DEBUG: EnemyMessager.received_message() called")
	emit_signal("received_message", msg)


## Returns true if we can raycast to the target area's location without hitting
## any walls
func _check_los(target) -> bool:
	# cast_to has to be RELATIVE to the ray
	los_ray.cast_to = target.global_position - los_ray.global_position
	#los_ray.cast_to = los_ray.global_position - target.global_position
	los_ray.force_raycast_update()
	#los_ray.force_update_transform()
	if get_owner().name == "Enemy":
		print("DEBUG: EnemyMessager._check_los(): Enemy's target's owner is %s" % target.get_owner().get_owner().name)
		Spawner.spawn_node(effect_scene.instance(), los_ray.global_position + los_ray.cast_to)
		Spawner.spawn_node(effect_scene.instance(), los_ray.global_position)
	# - debug
	#if los_ray.is_colliding():
		#var hit = los_ray.get_collider()
		#print("DEBUG: EnemyMessager._check_los(): los_ray collided with %s" % hit.name)
	#	pass
	#else:
	#	if get_owner().name == "Enemy":
	#		print("DEBUG: EnemyMessager._check_los(): Enemy was targeting %s and los_ray didn't collide with anything" % target.get_owner().get_owner().name)
	# - end debug
	return not los_ray.is_colliding() # only collides with walls
