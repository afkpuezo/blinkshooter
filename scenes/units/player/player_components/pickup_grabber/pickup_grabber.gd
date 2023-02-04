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

# fuck it, this is easier
onready var owner_resources := CombatResource.get_combat_resources(owner)


func _ready() -> void:
	var grab_shape := CircleShape2D.new()
	grab_shape.radius = grab_radius
	$CollisionShape2D.shape = grab_shape

	var vac_shape := CircleShape2D.new()
	vac_shape.radius = vacuum_radius
	pickup_vacuum.get_node("CollisionShape2D").shape = vac_shape


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
			var is_needed = false

			for cr in owner_resources:
				if cr.type == p.resource_type:
					is_needed = cr.value < cr.MAX_VALUE
					break

			if is_needed:
				emit_signal(
					"found_resource",
					p.resource_type,
					p.resource_amount
				)
				p.consume()


## vacuum any pickups currently in the vacuum area
func _physics_process(_delta: float) -> void:
	for a in pickup_vacuum.get_overlapping_bodies():
		# let's try just assuming it's a pickup
		a.set_vacuum_position(global_position)
