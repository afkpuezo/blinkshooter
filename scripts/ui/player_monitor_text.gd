extends CanvasLayer
class_name PlayerMonitorText
## Displays player combat stats through text


onready var label: Label = $Label
# NOTE: getting rid of this template is probably slower but its easier to add and remove values
#var _template: String = "Health: {hp} / {hp_max}\nEnergy: {nrg} / {nrg_max}\nAmmo: {ammo} / {ammo_max}\nBig Ammo: {big_ammo} / {big_ammo_max}"
var _values := {
	'hp': 0,
	'hp_max': 0,
	'nrg': 0,
	'nrg_max': 0,
	'ammo': 0,
	'ammo_max': 0,
	'big_ammo': 0,
	'big_ammo_max': 0,
	'current_weapon_slot': 0,
}


## Connect to events
func _ready() -> void:
# warning-ignore:return_value_discarded
	GameEvents.connect("player_combat_resource_value_changed", self, "update_resource_value")
# warning-ignore:return_value_discarded
	GameEvents.connect("player_changed_weapon", self, "update_current_weapon")


## Update text
func _process(_delta: float) -> void:
	#label.text = _template.format(_values)
	var lines = []
	for key in _values:
		var line = "\n%s: %d" % [key, _values[key]]
		lines.append(line)
	var text = String(lines)
	text.erase(0, 2)
	text.erase(text.length() - 1, 1)
	label.text = text


# ----------
# methods triggered by events
# ----------


func update_resource_value(msg: Dictionary):
	var v
	match msg['type']:
		CombatResource.Type.HEALTH:
			v = 'hp'
		CombatResource.Type.ENERGY:
			v = 'nrg'
		CombatResource.Type.BASIC_AMMO:
			v = 'ammo'
		CombatResource.Type.BIG_AMMO:
			v = 'big_ammo'
	_values[v] = msg['value']
	_values[v + "_max"] = msg['max']


func update_current_weapon(msg: Dictionary):
	_values['current_weapon_slot'] = msg['new_weapon_slot']
