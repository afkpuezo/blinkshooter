extends Area2D
class_name EnemyMessager
## When one enemy detects the player, it tells nearby enemies about it using this


signal received_message(msg)


## other enemies whose listeners are inside our sender can receive our messages
export var sender_radius := 128
export var listener_radius := 32

onready var ray: RayCast2D = $RayCast2D


func _ready() -> void:
	$CollisionShape2D.shape.sender_radius = sender_radius


## only sends messages to other enemies whose receiving areas are within our
## sender_radius AND in line-of-sight
func send_message(msg):
	print("DEBUG: EnemyMessager.send_message() called")
	for area in get_overlapping_areas():
		if area.has_method("receive_message"):
			area.receive_message(msg)
		else:
			print("DEBUG: EnemyMessager.send_message() found overlapping area that doesn't have receive_message(): %s " % area.name)


func receive_message(msg):
	print("DEBUG: EnemyMessager.received_message() called")
	emit_signal("received_message", msg)
