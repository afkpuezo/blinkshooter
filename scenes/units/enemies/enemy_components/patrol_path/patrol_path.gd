extends Node2D
class_name PatrolPath
## holds a collection of points that enemies patrol when idle
## points are configured by childing Node2Ds to this one, and nothing else
## should be added
## all points are global positions


enum LOOP_MODE{
	CYCLE, # after the last point, return the first point
	REVERSE, # after the last point, return the second-to-last point
}
export(LOOP_MODE) var loop_mode = LOOP_MODE.CYCLE

var points: Array = []
var current_point: Vector2
var current_index := 0
var current_delta := 1 # going left or right in reverse mode
var has_single_point: bool

## returns null if the given node doesn't have a patrol path attached
static func get_patrol_path(n: Node):
	if n.has_node("PatrolPath"):
		return n.get_node("PatrolPath")
	else:
		for c in n.get_children():
			if c.has_method("get_patrol_path"):
				return c
	return null


func _ready() -> void:
	for c in get_children():
		points.append(c.global_position)
		remove_child(c)
		c.queue_free()
	if points.empty():
		points.append(self.global_position)
	current_point = points[current_index]
	has_single_point = points.size() == 1


## updates the current point to the next one, according to the loop mode
func next_point():
	match loop_mode:
		LOOP_MODE.CYCLE:
			current_index += 1
			if current_index >= points.size():
				current_index = 0
		# end LOOP_MODE.CYCLE

		LOOP_MODE.REVERSE:
			current_index += current_delta

			if current_index >= points.size():
				current_index = points.size() - 2
				current_delta = -1
			elif current_index < 0:
				current_index = 0 if points.size() < 2 else 1
				current_delta = 1
		# end LOOP_MODE.REVERSE
	# end match
	current_point = points[current_index]
