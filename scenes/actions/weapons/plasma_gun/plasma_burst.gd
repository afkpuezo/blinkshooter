extends AreaOverTimeAttack
#tool disabled because the ready and process methods were running in editor
class_name PlasmaBurst
## when a plasma bullet explodes, it damages everything in an area. It also
## applies a zap effect to each hit target
## won't have any effect or start counting down on its duration until triggered


export(PackedScene) var zap_effect_scene
export var zap_duration := 3
export var are_zaps_green := true

export var radius := 128
export var duration := 1.0

var invert_pusher := false


func _ready() -> void:
	var shape := CircleShape2D.new()
	shape.radius = radius
	hit_box.get_node("CollisionShape2D").shape = shape
	$Timer.start(duration)
	if invert_pusher:
		$Pusher.strength *= -1


## trigged by signal from AOTA
func add_zap_effect(victim, _amount):
	var zap: ZapEffect = zap_effect_scene.instance()
	zap.is_green = are_zaps_green
	zap.duration = zap_duration
	victim.add_child(zap)
