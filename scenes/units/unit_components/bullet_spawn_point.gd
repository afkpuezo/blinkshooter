extends Node2D
class_name BulletSpawnPoint
## Serves as a location for bullets to come out of on characters.


## Returns true/false depending on if the given node has a bullet spawn point child node.
static func has_bullet_spawn_point(n: Node) -> bool:
	return get_bullet_spawn_point(n) != null


## Returns null if no child found.
static func get_bullet_spawn_point(n: Node) -> BulletSpawnPoint:
	for child in n.get_children():
		if child.get_class() == "BulletSpawnPoint":
			return child
	return null


## Has to be overriden or this will just return "Node2D"
func get_class() -> String:
	return "BulletSpawnPoint"
