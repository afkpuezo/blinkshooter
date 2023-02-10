extends Node2D
class_name HitApprover
## used by the saw blade attack to check if the target is behind a wall or not


var rays := []
export var num_clear_rays_required := 3


func _ready() -> void:
	#print("hit approver ready")
	for c in get_children():
		rays.append(c)


func approve_hit(victim: Unit) -> bool:
	#print("hit approver approve_hit()")
	var num_clear_rays := 0

	var victim_distance := global_position.distance_to(victim.global_position)

	for ray in rays:
		if is_ray_clear(ray, victim_distance):
			num_clear_rays += 1

	return num_clear_rays >= num_clear_rays_required


func is_ray_clear(ray: RayCast2D, victim_distance: float) -> bool:
	if ray.is_colliding():
		#print("ray %s is colliding" % ray.name)
		var col_distance = global_position.distance_to(ray.get_collision_point())
		return victim_distance < col_distance
	else:
		#print("ray %s is NOT colliding" % ray.name)
		return true
