extends Bullet
class_name PlasmaBullet
## special bullet that creates a burst to deal AOE damage


export var burst_damage := 50
export var burst_radius := 128
export var burst_duration := 1.0

export var is_burst_green := true

export(PackedScene) var burst_scene


## triggered from Bullet exploded signal
func spawn_burst() -> void:
	var burst: PlasmaBurst = burst_scene.instance()
	burst.damage = burst_damage
	burst.radius = burst_radius
	burst.duration = burst_duration
	burst.source = source
	burst.are_zaps_green = is_burst_green
	if not is_burst_green: # enemies push
		burst.invert_pusher = true

	Spawner.spawn_node(burst, global_position)
