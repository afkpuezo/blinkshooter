extends KinematicBody2D
class_name Bullet
## the root node of the generic bullet scene
## Flies forward until it hits something or times out


signal exploded()


export var has_explosion := true
export var is_homing := false

# these are set by weapon
var forgiveness_layer :=  0b10
var forgiveness_duration := 0.25
onready var forgiveness_timer: Timer = $ForgivenessTimer

var initial_velocity: Vector2
onready var mover: BulletMover = $BulletMover


## damage dealt to target when hit, set by weapon
var damage = 1
## the unit responsible for shooting this bullet
var source
## only actually used by homing bullets I guess
var target


func _ready() -> void:
	mover.set_initial_velocity(initial_velocity)
	forgiveness_timer.start(forgiveness_duration)
	if target:
		target.connect("died", self, "on_target_death")
	if source:
		source.connect("died", self, "on_source_death")


## handles collisions with things that can be hurt, EG units
func _on_HitBox_area_entered(area: Area2D) -> void:
	var is_forgivable := (not forgiveness_timer.is_stopped()) and area.collision_layer & forgiveness_layer != 0

	if (not is_forgivable) and area.has_method("get_unit"):
		handle_hit(area.get_unit())


func handle_hit(victim: Unit):
	victim.take_damage(damage, source)
	end()


func end(do_explode := has_explosion):
	if do_explode:
		emit_signal("exploded")
	queue_free()


## avoids crash after target is freed
func on_target_death():
	target = null


## avoids crash after source is freed
func on_source_death():
	source = null
