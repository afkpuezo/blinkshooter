extends Node2D
class_name EnemyMessager
## When one enemy detects the player, it tells nearby enemyies about it using this
## NOTE: this LOS solution will end up duplicating work between different
## target and might be perfomance intensive. Might have to change to a smarter
## system later


signal received_message(msg)


## other target whose receivers are inside our sender can hear our messages
export var sender_radius := 128
export var receiver_radius := 32


## messaging related
export var num_rays := 3

var rays := {} # maps rays to true/false if they are in-use
var current_targets := {} # maps target to the ray watching them. null if no ray


# refs to nodes
onready var sender: Area2D = $Sender
onready var receiver: Area2D = $Receiver


# ----------
# setup
# ----------

func _ready() -> void:
	# set size of areas
	var send_shape := CircleShape2D.new()
	send_shape.radius = sender_radius
	sender.get_node("CollisionShape2D").shape = send_shape

	var rec_shape := CircleShape2D.new()
	rec_shape.radius = receiver_radius
	receiver.get_node("CollisionShape2D").shape = rec_shape
	# rays
	_setup_rays()


## i guess this should use parameters rather than having side effects but I
## can't be bothered
func _setup_rays():
	for _x in range(num_rays):
		# no need to set enabled or cast_to in here
		var ray = RayCast2D.new()
		receiver.add_child(ray)
		ray.exclude_parent = true
		ray.collision_mask = 0b1 # walls
		ray.collide_with_areas = true
		ray.collide_with_bodies = true
		rays[ray] = false


# ----------
# running methods
# ----------


func _process(_delta: float) -> void:
	update_ray_cast_tos()


## should be called periodically
func update_ray_cast_tos():
	for target in current_targets:
		var ray = current_targets[target]
		if ray:
			ray.cast_to = ray.to_local(target.global_position)


## if there's an unused ray, assigh it to this target. otherwise just keep track
## of this new target for later
## called from signal from Sender area
## only adds if target can receive messages
func add_target(target):
	if not target.has_method("receive_message"):
		return
	if target == receiver: # dont send messages to our own receiver
		return

	var ray: RayCast2D = null

	# look for a ray that's not in use
	for temp_ray in rays:
		if rays[temp_ray] == false:
			ray = temp_ray
			ray.enabled = true
			break
	# end for
	_assign_ray_to_target(ray, target)


## remove this target from current_targets. if it had an assigned ray, free that
## ray.
## if there was an enemy waiting for that ray, assign it to the waiting enemy
## called from signal from Sender area
func remove_target(target):
	if target == receiver: # when the enemy dies, the receiver area leaves
		return

	var ray: RayCast2D = current_targets[target]

	var removed = current_targets.erase(target)
	if not removed:
		return

	var unassign_ray = true

	if ray:
		# look for a replacement enemy
		for target in current_targets:
			if current_targets[target] == null:
				_assign_ray_to_target(ray, target)
				unassign_ray = false

		if unassign_ray:
			rays[ray] = false
			ray.enabled = false
# end remove_target()


## handles null ray
func _assign_ray_to_target(ray: RayCast2D, target):
	# checking if the ray is inside the tree avoids some error messages upon
	# loading a level
	if ray and ray.is_inside_tree():
		rays[ray] = true
		ray.enabled = true
		ray.cast_to = ray.to_local(target.position)
		ray.force_raycast_update()
	current_targets[target] = ray


## send the given message to enemies within LOS
func send_message(msg):
	for target in current_targets:
		var ray: RayCast2D = current_targets[target]
		if ray:
			if not ray.is_colliding():
				target.receive_message(msg)


func receive_message(msg):
	#print("DEBUG: targetMessager.received_message() called")
	emit_signal("received_message", msg) # should go to Enemy.receive_enemy_message()

