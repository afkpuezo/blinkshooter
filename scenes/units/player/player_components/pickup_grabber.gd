extends Area2D
class_name PickupGrabber
## Hands an item to the player when they walk over one


signal found_item(item)


func on_area_entered(area) -> void:
	if area.has_method("get_item"):
		emit_signal(
			"found_item",
			area.get_item()
		)
