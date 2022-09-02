extends Mover
class_name EnemyMover
## idles until the player gets close enough, then points at the player
## beginning to wonder if this Mover idea won't work for this kind of thing

onready var player_detection: Area2D = $PlayerDetection


# -----
# inherited from Mover
# -----


## The given unit should be the user/owner of this Mover.
## That unit should call this method during it's _physics_update() method.
func physics_update(unit, movement_stats: MovementStats, delta: float):
	var player = unit.get_player_if_detected()

	if player:
		unit.look_at(player.position)
		var direction: Vector2 = (player.position - unit.position).normalized()
		accelerate_towards(unit, movement_stats, delta, direction)
	else: # if no player found
		apply_friction(unit, movement_stats, delta)

	unit.move_and_slide(movement_stats.velocity)
