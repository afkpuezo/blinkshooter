extends Node
class_name CombatResource
## Represents a single Resource/bar for a character, eg health or energy

signal value_changed(new_value)

enum CombatResourceType {HEALTH, ENERGY}

export var MAX_VALUE: float = 100.0
export var MIN_VALUE: float = 0.0 # needed?
export var REGEN_PER_SECOND: float = 0.0
export(CombatResourceType) var type = CombatResourceType.HEALTH
export var is_player := false ## If set to true, will trigger relevant events

onready var current_value := MAX_VALUE


## report max value for set up
func _ready() -> void:
	_report_value_change(0)


## Apply regen - NOTE: should that be only every second?
func _process(delta: float) -> void:
	if REGEN_PER_SECOND >= 0:
		increase_value(REGEN_PER_SECOND * delta)
	else:
		decrease_value(REGEN_PER_SECOND * delta)


## if the value is not already maxed increase current value by the given amount
## and return true.
## if the value is already maxed, return false.
func increase_value(amount: float) -> bool:
	if current_value == MAX_VALUE:
		return false
	else:
		current_value = min(MAX_VALUE, current_value + amount)
		_report_value_change(amount)
		return true


## if the value is not already at the minimum, decrease current value by the
## given amount and return true.
## if the value is already at the minimum, return false.
func decrease_value(amount: float) -> bool:
	if current_value == MIN_VALUE:
		return false
	else:
		current_value = max(MIN_VALUE, current_value + amount)
		_report_value_change(amount * -1)
		return true


# ----------
# private methods
# ----------


## change is the amount that the value changed
func _report_value_change(change: float):
	emit_signal("value_changed", current_value)
	if is_player:
		GameEvents.emit_signal(
				"player_combat_resource_value_changed",
				{
					"type": type,
					"value": current_value,
					"change": change,
					"max": MAX_VALUE,
				})
