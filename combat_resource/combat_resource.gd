extends Node
class_name CombatResource
## Represents a single Resource/bar for a character, eg health or energy

signal value_changed(new_value)

enum Type {HEALTH, ENERGY}

export var MAX_VALUE := 100
export var MIN_VALUE := 0 # needed?
export var REGEN := 0
export(float, 0.1, 3.0) var REGEN_PERIOD = 0.1
export(Type) var type = Type.HEALTH
export var is_player := false ## If set to true, will trigger relevant events

onready var value := MAX_VALUE


## report max value for set up, create regen timer
func _ready() -> void:
	_report_value_change(0)
	var timer := Timer.new()
	timer.connect("timeout", self, "_apply_regen")
	add_child(timer)
	timer.start(REGEN_PERIOD)


# ----------
# public methods
# ----------


## can take a positive or negative value, ignores 0
## if there would be no change (eg healing when at max), does nothing
## returns true if the value was changed, false otherwise
func change_value(amount: int) -> bool:
	var was_changed := false
	if amount > 0:
		was_changed = _increase_value(amount)
	elif amount < 0:
		was_changed = _decrease_value(amount)
	if was_changed:
		_report_value_change(amount)
	return was_changed


# ----------
# private methods
# ----------


## triggered by timer
func _apply_regen():
	change_value(REGEN)


## if the value is not already maxed increase current value by the given amount
## and return true.
## if the value is already maxed, return false.
func _increase_value(amount: int) -> bool:
	if value == MAX_VALUE:
		return false
	else:
		value = min(MAX_VALUE, value + amount)
		return true


## if the value is not already at the minimum, decrease current value by the
## given amount and return true.
## if the value is already at the minimum, return false.
func _decrease_value(amount: int) -> bool:
	if value == MIN_VALUE:
		return false
	else:
		value = max(MIN_VALUE, value + amount)
		return true



## change is the amount that the value changed
func _report_value_change(change: int):
	emit_signal("value_changed", value)
	if is_player:
		GameEvents.emit_signal(
				"player_combat_resource_value_changed",
				{
					"type": type,
					"value": value,
					"change": change,
					"max": MAX_VALUE,
				})
