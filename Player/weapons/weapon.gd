extends Action
class_name Weapon
## This is an base class for simple individual player weapons. When triggered, creates the
## appropriate bullet at the user's BulletSpawnPoint. Also keeps track of its own ammo
## NOTE: trying having it extend Action
## NOTE: may be used for enemy weapons at some point as well.

export(PackedScene) var bullet_scene

# ----------
# virtual methods from Action
# ----------

## shoot da bullet
## TODO flesh out
func do_action():
	#print("DEBUG: Weapon.do_action() called")
	GameSpawner.spawn_node(bullet_scene.instance(), user.position, user.rotation)
