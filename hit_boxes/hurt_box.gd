extends Area2D
class_name HurtBox
## Defines where a Unit takes damage.


signal took_damage(amount, source)


func take_damage(amount: int, source):
	emit_signal("took_damage", amount, source)
