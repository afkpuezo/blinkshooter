extends Bullet
class_name ShotgunPellet
## pierces targets


## don't end the bullet
## because it's on enter, will only damage each target once
func handle_hit(victim: Unit):
		victim.take_damage(damage, source)
		emit_signal("exploded")
