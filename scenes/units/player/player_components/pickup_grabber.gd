extends Area2D
class_name PickupGrabber
## Hands an item to the player when they walk over one
## Now takes care of figuring out what kind of pickup it is and sends it to the
## correct Player component (through seperate signals)


signal found_weapon(item)
signal found_action(item)
signal found_resource(item)


## TODO think about typing, it's all over the place here
func on_area_entered(p: Pickup) -> void:
	var signal_name: String
	match p.meta_type:
		Pickup.META_TYPE.ACTION:
			signal_name = "found_action"
		Pickup.META_TYPE.WEAPON:
			signal_name = "found_weapon"
		Pickup.META_TYPE.RESOURCE:
			signal_name = "found_resource"

	emit_signal(
		signal_name,
		p.get_item()
	)
