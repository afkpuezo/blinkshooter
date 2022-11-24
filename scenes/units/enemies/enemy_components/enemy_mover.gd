extends Mover
class_name EnemyMover
## idles until the player gets close enough, then points at the player
## beginning to wonder if this Mover idea won't work for this kind of thing


onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
onready var nav_update_timer: Timer = $NavUpdateTimer


# -----
# inherited from Mover
# -----


## NOTE - trying a new idea where the enemy decided behavior in its own script and calls the
## appropriate movement method directly.
func physics_update(_unit, _movement_stats: MovementStats, _delta: float):
	pass


# -----
# helpers for movement
# -----


## uses the pathing system to move towards the given point (probably either the
## player's current or last-known location)
func move_to(
	unit,
	movement_stats: MovementStats,
	delta: float,
	target_position: Vector2
	):
	_update_pathing(target_position)
	var next_location = nav_agent.get_next_location()
	#print("DEBUG: EnemyMover.move_to(): next_location is %s" % next_location)
	var direction: Vector2 = unit.position.direction_to(next_location).normalized()
	accelerate_towards(movement_stats, delta, direction)
	unit.move_and_slide(movement_stats.velocity)


## if the reset timer has expired, update the nav agent's target position and restart the timer
## this should only be called when the player is detected and being chased
func _update_pathing(new_target_location: Vector2):
	if nav_update_timer.is_stopped():
		#print("DEBUG: EnemyMover._update_pathing(): setting new target location")
		nav_agent.set_target_location(new_target_location)
		nav_update_timer.start()


## moves backwards away from the given point
## called when the player is detected too close for comfort and the enemy wants
## to back away
func back_away_from(
	unit,
	movement_stats: MovementStats,
	delta: float,
	target_position: Vector2
	):
	var direction: Vector2 = (target_position - unit.position).normalized() * -1
	accelerate_towards(movement_stats, delta, direction)
	unit.move_and_slide(movement_stats.velocity)


## just a rename of apply_friction, called from the outside
## NOTE: target_position arg may be ignored, just included to match other methods
func stand_still(
	unit,
	movement_stats: MovementStats,
	delta: float,
	_target_position = null
	):
	apply_friction(movement_stats, delta)
	unit.move_and_slide(movement_stats.velocity)