extends Action
class_name Weapon
## This is an base class for simple individual player weapons. When triggered, creates the
## appropriate bullet at the user's BulletSpawnPoint. Also keeps track of its own ammo


export(PackedScene) var bullet_scene
var spawn_location: Node2D
var user_movement_stats: MovementStats
export var damage := 1
export(CombatResource.Type) var main_ammo_type # for ui purposes

enum TEAM {PLAYER, ENEMY, BOTH}
export(TEAM) var forgiveness_team = TEAM.PLAYER
var forgiveness_layer :=  0b0 # set in ready
export var forgiveness_duration := 0.25


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

	var bullet: Bullet = bullet_scene.instance()
	configure_bullet(bullet)
	Spawner.spawn_bullet(
		bullet,
		spawn_location.get_global_position(),
		user.get_global_rotation(),
		user_movement_stats.velocity)


## lets child weapon types override
func configure_bullet(bullet: Bullet):
	bullet.damage = damage
	bullet.source = user
	bullet.forgiveness_layer = forgiveness_layer
	bullet.forgiveness_duration = forgiveness_duration


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
