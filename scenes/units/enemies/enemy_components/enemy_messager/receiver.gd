extends Area2D
class_name Receiver
## used in the EnemyMessager scene, receives and passes on messages from other
## enemies about the player


signal message_received(msg)


func receive_message(msg):
	emit_signal("message_received", msg)
