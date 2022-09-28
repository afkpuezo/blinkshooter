extends Mover
class_name EnemyMover
## idles until the player gets close enough, then points at the player
## beginning to wonder if this Mover idea won't work for this kind of thing


export var stop_chasing_threshold := 200
onready var chasing_squared = pow(stop_chasing_threshold, 2) # faster calculations apparently

export var too_close_threshold := 100
onready var too_close_squared = pow(too_close_threshold, 2)

onready var nav_agent: NavigationAgent2D = $NavigationAgent2D


# -----
# inherited from Mover
# -----


## The given unit should be the user/owner of this Mover.
## That unit should call this method during it's _physics_update() method.
## Giving a type hint to the unit causes cyclical dependency issues
func physics_update(unit, movement_stats: MovementStats, delta: float):
	var player = unit.get_player_if_detected()

	if player:
		unit.look_at(player.position)
		var distance_to_player = unit.position.distance_squared_to(player.position)
		if distance_to_player > chasing_squared:
			_chase_player(unit, movement_stats, delta, player)
		elif distance_to_player < too_close_squared:
			_back_away_from_player(unit, movement_stats, delta, player)
		else: # if in the sweet spot
			apply_friction(unit, movement_stats, delta)
	else: # if no player found
		apply_friction(unit, movement_stats, delta)

	unit.move_and_slide(movement_stats.velocity)


# -----
# helpers for movement
# -----


## called when the player is detected AND far enough away that the enemy will chase them
func _chase_player(unit, movement_stats: MovementStats, delta: float, player):
	var direction: Vector2 = (player.position - unit.position).normalized()
	accelerate_towards(unit, movement_stats, delta, direction)


## called when the player is detected too close for comfort and the enemy wants to back away
func _back_away_from_player(unit, movement_stats: MovementStats, delta: float, player):
	var direction: Vector2 = (player.position - unit.position).normalized() * -1
	accelerate_towards(unit, movement_stats, delta, direction)
