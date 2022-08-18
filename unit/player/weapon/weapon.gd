extends Action
class_name Weapon
## This is an base class for simple individual player weapons. When triggered, creates the
## appropriate bullet at the user's BulletSpawnPoint. Also keeps track of its own ammo
## NOTE: may be used for enemy weapons at some point as well.

export(PackedScene) var bullet_scene
var spawn_location_source: Node2D
var user_movement_stats: MovementStats

# ----------
# virtual methods from Action
# ----------

## shoot da bullet
## TODO flesh out
func do_action():
	# spawn_location_source is set up here since the user var might not be configured at ready time
	# should only happen once
	if not spawn_location_source:
		spawn_location_source = BulletSpawnPoint.get_bullet_spawn_point(user)
		if not spawn_location_source:
			spawn_location_source = user

	# ditto with the setup here
	if not user_movement_stats:
		user_movement_stats = MovementStats.get_movement_stats(user) # assume it has one

	GameSpawner.spawn_bullet(
		bullet_scene.instance(),
		spawn_location_source.get_global_position(),
		user.get_global_rotation(),
		user_movement_stats.velocity)