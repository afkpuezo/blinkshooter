extends Weapon
class_name PlasmaGun
## probably overkill to extend this here, but this gun has an extra burst_damage
## var since the bullet has a burst component


export var burst_damage := 50


func configure_bullet(bullet: Bullet):
	bullet.burst_damage = burst_damage
	.configure_bullet(bullet)


