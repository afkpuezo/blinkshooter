extends Area2D
class_name HitBox
## Bullets and attacks have these


func get_class() -> String:
	return "HitBox"


## TODO: better way of doing this?
func get_damage() -> int:
	return owner.damage
