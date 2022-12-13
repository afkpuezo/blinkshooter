extends Bullet
class_name ShotgunPellet
## pierces targets


## don't end the bullet
## because it's on enter, will only damage each target once
func _on_HitBox_area_entered(area) -> void:
	if area.has_method("get_unit"):
		var victim: Unit = area.get_unit()
		victim.take_damage(damage, source)
		emit_signal("exploded")
