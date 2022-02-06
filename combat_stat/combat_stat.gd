extends Node
class_name CombatStat
## Represents a single stat/bar for a character, eg health or energy

signal value_changed(new_value)

enum CombatStatType {HEALTH, ENERGY}

export var MAX_VALUE: float = 100.0
export var MIN_VALUE: float = 0.0 # needed?
export var REGEN_PER_SECOND: float = 0.0
export(CombatStatType) var type = CombatStat.HEALTH
export var is_player := false ## If set to true, will trigger relevant events

onready var current_value := MAX_VALUE


## Apply regen - NOTE: should that be only every second?
func _process(delta: float) -> void:
	increase_value(REGEN_PER_SECOND * delta)


## if the value is not already maxed increase current value by the given amount
## and return true.
## if the value is already maxed, return false.
func increase_value(amount: float) -> bool:
	if current_value == MAX_VALUE:
		return false
	else:
		_change_value(amount)
		return true


## if the value is not already at the minimum, decrease current value by the
## given amount and return true.
## if the value is already at the minimum, return false.
func decrease_value(amount: float) -> bool:
	if current_value == MIN_VALUE:
		return false
	else:
		_change_value(amount * -1)
		return true


# ----------
# private methods
# ----------


func _change_value(amount: float):
	current_value = min(MAX_VALUE, current_value + amount)
	emit_signal("value_changed", current_value)
	if is_player:
		GameEvents.emit_signal(
				"player_combat_stat_value_changed",
				{
					"combat_stat_type": type,
					"new_value": current_value,
				})
