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

onready var current_value := MAX_VALUE


## report max value for set up, create regen timer
func _ready() -> void:
	_report_value_change(0)
	var timer := Timer.new()
	timer.connect("timeout", self, "apply_regen")
	add_child(timer)
	timer.start(REGEN_PERIOD)
	print("DEBUG: timer added")


## triggered by timer
func apply_regen():
	print("DEBUG: apply_regen")
	if REGEN > 0:
		increase_value(REGEN)
	elif REGEN < 0:
		decrease_value(REGEN)
	# does nothing if exactly 0


## if the value is not already maxed increase current value by the given amount
## and return true.
## if the value is already maxed, return false.
func increase_value(amount: int) -> bool:
	if current_value == MAX_VALUE:
		return false
	else:
		current_value = min(MAX_VALUE, current_value + amount)
		_report_value_change(amount)
		return true


## if the value is not already at the minimum, decrease current value by the
## given amount and return true.
## if the value is already at the minimum, return false.
func decrease_value(amount: int) -> bool:
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
func _report_value_change(change: int):
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
