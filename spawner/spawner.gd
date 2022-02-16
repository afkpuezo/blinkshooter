extends Node2D
class_name Spawner
## Autoload singleton that handles spawning new objects that need to be unattached from their
## creators.
## May be extended by spawners for specific objects (eg bullets)?
# TODO: make this a component of a world node, rather than a singleton?


## places the given Node2D at the given location and adds it to the scene tree
func spawn_node(node: Node2D, location: Vector2):
	node.position = location
	add_child(node) # TODO: spawn them somewhere else?
