extends Node2D
class_name EnemyMessager
## When one enemy detects the player, it tells nearby enemies about it using this


signal received_message(msg)


## other enemies whose receivers are inside our sender can hear our messages
## NOTE: I think this only works if sender is longer than receiver
export var sender_radius := 128
export var receiver_radius := 32
const RAY_OFFSET := 1 # LOSRay is placed this far past the receiver radius


# refs to nodes
onready var sender: Area2D = $Sender
onready var receiver: Area2D = $Receiver
# rotate the pivot to keep the ray at a fixed radius
onready var los_pivot: Node2D = $LOSPivot
onready var los_ray: RayCast2D = $LOSPivot/LOSRay


func _ready() -> void:
	print("DEBUG: EnemyMessager._ready(): radii are %d - %d" % [sender_radius, receiver_radius])
	# set size of areas
	sender.get_node("CollisionShape2D").shape.radius = sender_radius
	receiver.get_node("CollisionShape2D").shape.radius = receiver_radius
	# the ray should start just outside our receiver to avoid sending to
	# ourselves, but reach the same point as our sender radius
	los_ray.position = Vector2(receiver_radius + RAY_OFFSET, 0)
	los_ray.cast_to = Vector2(sender_radius, 0)


## only sends messages to other enemies whose receiving areas are within our
## sender_radius AND in line-of-sight
func send_message(msg):
	print("DEBUG: EnemyMessager.send_message() called")
	for area in sender.get_overlapping_areas():
		if area.has_method("receive_message"):
			if _check_los(area):
				area.receive_message(msg)
			else:
				print("DEBUG: EnemyMessager.send_message() check_los() call failed")
				pass
		else:
			print("DEBUG: EnemyMessager.send_message() found overlapping area that doesn't have receive_message(): %s " % area.name)


func receive_message(msg):
	print("DEBUG: EnemyMessager.received_message() called")
	emit_signal("received_message", msg)


## Returns true if we can raycast to the target area's location without hitting
## any walls
func _check_los(target) -> bool:
	los_pivot.look_at(target.global_position)
	los_ray.force_raycast_update()
	return los_ray.is_colliding() # only collides with walls
