extends Weapon
class_name Shotgun
## extends the weapon class so it can shoot multiple bullets


# bullets are spread evenly
export var num_bullets := 5
export var max_angle_deg := 45.0
onready var max_angle := deg2rad(max_angle_deg)

var angles := []


# ----------
# new to Shotgun
# ----------


## calculate the angles
## unlike the enemy vision, no guarantee one ends up in the middle
func _ready() -> void:
	var angle_range := max_angle * 2
	var step = angle_range / (num_bullets - 1)

	for n in range(num_bullets):
		angles.append(max_angle - (step * n))


# ----------
# from Weapon
# ----------


## extend to make multiple bullets
func create_bullet():
	for n in range(num_bullets):
		var bullet: Bullet = bullet_scene.instance()
		configure_bullet(bullet)
		Spawner.spawn_bullet(
			bullet,
			spawn_location.get_global_position(),
			user.get_global_rotation() + angles[n],
			user_movement_stats.velocity)
