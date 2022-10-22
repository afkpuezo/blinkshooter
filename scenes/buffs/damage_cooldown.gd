extends Node2D
class_name DamageCooldown
## Some attacks are bullets and deal damage once and stop. Others persist
## for a period of time, but can only damage an individual target once in a
## given period. This buff exists to track that timer on victims of the attack


var source # the attack/action/bullet causing this buff
var duration # time in seconds it lasts


## Can this be called before adding the node to the tree?
func setup(source, duration):
	self.source = source
	self.duration = duration


func _ready() -> void:
	$Timer.start(duration)


func _on_Timer_timeout() -> void:
	get_parent().remove_child(self)
	self.queue_free()
