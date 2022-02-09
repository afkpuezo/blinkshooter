extends CanvasLayer
class_name PlayerMonitorText
## Displays player combat stats through text


onready var label: Label = $Label
var _template: String = "Health: {hp} / {hp_max}\nEnergy: {nrg} / {nrg_max}"
var _values := {
	'hp': 0,
	'hp_max': 0,
	'nrg': 0,
	'nrg_max': 0,
}


## Connect to events
func _ready() -> void:
	GameEvents.connect("player_combat_resource_value_changed", self, "update_value")


## Update text
func _process(delta: float) -> void:
	label.text = _template.format(_values)


# ----------
# methods triggered by events
# ----------


func update_value(msg: Dictionary):
	match msg['type']:
		CombatResource.CombatResourceType.HEALTH:
			_values['hp'] = msg['value']
			_values['hp_max'] = msg['max']
		CombatResource.CombatResourceType.ENERGY:
			_values['nrg'] = msg['value']
			_values['hp_max'] = msg['max']
