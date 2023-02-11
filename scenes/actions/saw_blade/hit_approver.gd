extends Node2D
class_name HitApprover
## used by the saw blade attack to check if the target is behind a wall or not


var rays := []
export var num_valid_rays_required := 3


func _ready() -> void:
	for c in get_children():
		rays.append(c)


func approve_hit(victim: Unit) -> bool:
	var num_valid_rays := 0

	for ray in rays:
		if is_ray_valid(ray, victim):
			num_valid_rays += 1
			if num_valid_rays >= num_valid_rays_required:
				return true

	return false


## valid if the ray hits the victi
func is_ray_valid(ray: RayCast2D, victim: Unit) -> bool:
	var return_val := false

	while true:
		if ray.is_colliding():
			var collider = ray.get_collider()

			if collider is Unit:
				if collider == victim:
					return_val = true
					break
				else: # wrong enemy, so ignore it and try again
					ray.add_exception(collider)
					ray.force_raycast_update()
					continue
			else: # it's a wall
				break
		else: # not colliding anything
			break

	ray.clear_exceptions()
	return return_val
