extends Area2D
class_name PickupGrabber
## Hands an item to the player when they walk over one
## Now takes care of figuring out what kind of pickup it is and sends it to the
## correct Player component (through seperate signals)


signal found_weapon(item)
signal found_action(item)
signal found_resource(type, amount)

export var grab_radius := 32
export var vacuum_radius := 128

onready var pickup_vacuum: Area2D = $PickupVacuum # should this have its own script?


func _ready() -> void:
	$CollisionShape2D.shape.radius = grab_radius
	pickup_vacuum.get_node("CollisionShape2D").shape.radius = vacuum_radius


# from our own Area2D Signal
func grab(p: Pickup):
	match p.meta_type:
		Pickup.META_TYPE.ACTION:
			emit_signal(
				"found_action",
				p.get_item()
			)
		Pickup.META_TYPE.WEAPON:
			emit_signal(
				"found_weapon",
				p.get_item()
			)
		Pickup.META_TYPE.RESOURCE:
			var resource_details := p.get_resource_type_and_amount()
			emit_signal(
				"found_resource",
				resource_details[0],
				resource_details[1]
			)


## vacuum any pickups currently in the vacuum area
func _physics_process(_delta: float) -> void:
	for a in pickup_vacuum.get_overlapping_areas():
		# let's try just assuming it's a pickup
		a.set_vacuum_position(global_position)
