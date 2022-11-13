extends Action
class_name SawBladeAction
## Creates a saw blade in front of the player character for a brief amount of time, to serve
## as a melee attack


onready var saw_blade_attack: SawBladeAttack = $SawBladeAttack
onready var timer: Timer = $Timer


func _ready() -> void:
	disable()


## inherited from Action
##

func set_user(new_user):
	saw_blade_attack.user = new_user
	.set_user(new_user)


func do_action():
	enable()
	timer.start()


func enable():
	saw_blade_attack.user = user
	add_child(saw_blade_attack)


func disable():
	remove_child(saw_blade_attack)
	timer.stop()


func _on_Timer_timeout() -> void:
	disable()
