extends Action
class_name Weapon
## This is an base class for simple individual player weapons. When triggered,
## creates the appropriate bullet at the user's BulletSpawnPoint. Also keeps
## track of its own ammo
## NOTE: This probably should have been a scene from the start, but it's easier
## to keep it as a node for now


# a little redundant but i'm just not going to worry about it
signal recoiled(user)


export(PackedScene) var bullet_scene
var spawn_location: Node2D
var user_movement_stats: MovementStats
export var damage := 1
export(CombatResource.Type) var main_ammo_type # for ui purposes

enum TEAM {PLAYER, ENEMY, BOTH}
export(TEAM) var forgiveness_team = TEAM.PLAYER
var forgiveness_layer :=  0b0 # set in ready
export var forgiveness_duration := 0.25

# will create a Pusher if recoil is not 0
export var recoil := 0.0


# ----------
# static methods
# ----------


static func is_weapon(w) -> bool:
	return w.has_method("is_weapon")


# ----------
# virtual methods from Action
# ----------


## shoot da bullet
func do_action():
	_ready_spawn_location()
	_ready_user_movement_stats()

	create_bullet()

	emit_signal("recoiled", user)


## extendable helper
func create_bullet():
	var bullet: Bullet = bullet_scene.instance()
	configure_bullet(bullet)

	Spawner.spawn_node(
		bullet,
		spawn_location.get_global_position(),
		user.get_global_rotation()
	)


## extendable helper
func configure_bullet(bullet: Bullet):
	bullet.damage = damage
	bullet.source = user
	bullet.forgiveness_layer = forgiveness_layer
	bullet.forgiveness_duration = forgiveness_duration
	bullet.initial_velocity = user_movement_stats.velocity
	bullet.target = target


# ----------
# unique to Weapon
# ----------


func _ready() -> void:
	# I probably should have had a constants/defiles file for stuff like this
	match forgiveness_team:
		TEAM.PLAYER:
			forgiveness_layer = 0b10
		TEAM.ENEMY:
			forgiveness_layer = 0b100
		TEAM.BOTH:
			forgiveness_layer = 0b110
	# handle recoil
	if recoil != 0:
		var pusher: Pusher = Pusher.new() # problems if switch to scene later?
		add_child(pusher)
		pusher.strength = recoil
		pusher.position.x = 10
		pusher.start_distance_falloff = 100
		pusher.end_distance_falloff = 200
		# warning-ignore:return_value_discarded
		connect("recoiled", pusher, "push")


## spawn_location is set up here since the user var might not be configured at ready time
## should only actually happen once
func _ready_spawn_location():
	if not spawn_location:
		spawn_location = BulletSpawnPoint.get_bullet_spawn_point(user)
		if not spawn_location:
			spawn_location = user


## user_movement_stats is set up here since the user var might not be configured at ready time
## should only actually happen once
func _ready_user_movement_stats():
	if not user_movement_stats:
		user_movement_stats = MovementStats.get_movement_stats(user) # assume it has one
