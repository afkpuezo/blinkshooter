extends Node2D
#class_name Spawner no class name for singleton
## Autoload singleton that handles spawning new objects that need to be unattached from their
## creators.
## May be extended by spawners for specific objects (eg bullets)?
# TODO: make this a component of a world node, rather than a singleton?


func _ready() -> void:
	# warning-ignore:return_value_discarded
	GameEvents.connect("level_loaded", self, "cleanup")


func cleanup(_args = null):
	for c in get_children():
		remove_child(c)
		c.queue_free()


## places the given Node2D at the given spawn_position and adds it to the scene tree
## if spawn_rotation is specified, the spawned node will be rotated
func spawn_node(
		node: Node2D,
		spawn_position: Vector2,
		spawn_rotation := 0.0,
		spawn_delay := 0.0):

	if spawn_delay > 0.0:
		yield(get_tree().create_timer(spawn_delay), "timeout")

	node.translate(spawn_position)
	node.rotate(spawn_rotation)
	call_deferred("add_child", node)
