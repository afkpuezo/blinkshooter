extends KinematicBody2D
class_name DeathParticle
## several of these are spawned when a unit dies, flying in random directions


# child nodes
onready var sprite: Sprite = $Sprite


# the sprite rotates, but not the entire scene
export var move_speed := 0
export var sprite_rotation_speed_deg := 0.0
onready var sprite_rotation_speed_rad = deg2rad(sprite_rotation_speed_deg)
export var lifespan := 1.0
export var modulation: Color


# ----------
# methods
# ----------


## should be called BEFORE ready? might not matter
func configure_particle(
	new_move_speed,
	new_rotation_speed_deg,
	new_modulation
	):
	print("configure_particle()")
	move_speed = new_move_speed
	sprite_rotation_speed_deg = new_rotation_speed_deg
	modulation = new_modulation


func _ready() -> void:
	$LifeTimer.start(lifespan)
	if modulation:
		#sprite.modulate = modulation
		sprite.set_modulate(modulation)


func _physics_process(delta: float) -> void:
	if move_and_collide(Vector2(move_speed * delta, 0).rotated(rotation)):
		end()
	sprite.rotate(sprite_rotation_speed_rad * delta)


## called by timer or collision
func end():
	queue_free()

