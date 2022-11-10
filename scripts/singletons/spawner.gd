extends Node2D
#class_name Spawner no class name for singleton
## Autoload singleton that handles spawning new objects that need to be unattached from their
## creators.
## May be extended by spawners for specific objects (eg bullets)?
# TODO: make this a component of a world node, rather than a singleton?


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
	#add_child(node) # TODO: spawn them somewhere else?
	call_deferred("add_child", node)


## bullets have a specific method to deal with the "initial velocity" parameter
## that is, including the player's current momentum in the bullet's
func spawn_bullet(
		bullet: Bullet,
		spawn_position: Vector2,
		spawn_rotation,
		initial_velocity: Vector2):
	bullet.set_initial_velocity(initial_velocity)
	spawn_node(bullet, spawn_position, spawn_rotation)
