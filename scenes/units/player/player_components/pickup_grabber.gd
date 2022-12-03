extends Area2D
class_name PickupGrabber
## Hands an item to the player when they walk over one
## Now takes care of figuring out what kind of pickup it is and sends it to the
## correct Player component (through seperate signals)


signal found_weapon(item)
signal found_action(item)
signal found_resource(type, amount)


func on_area_entered(p: Pickup) -> void:
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
