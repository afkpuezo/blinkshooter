extends CanvasLayer
class_name PlayerMonitorText
## Displays player combat stats through text


onready var label: Label = $Label

var values: Dictionary# = _setup_values()
var template: String# = _setup_template()

# used as keys in dict/methods
const COMBAT_RESOURCES := "combat_resources"
const CURRENT := "current"
const VALUE := "value"
const MAX := "max"
const TYPE := "type"

const CURRENT_WEAPON_SLOT := "current_weapon_slot"
const NEW_WEAPON_SLOT := "new_weapon_slot"


## Connect to events
func _ready() -> void:
	# connect signals
# warning-ignore:return_value_discarded
	GameEvents.connect("player_combat_resource_value_changed", self, "update_resource_value")
# warning-ignore:return_value_discarded
	GameEvents.connect("player_changed_weapon", self, "update_CURRENT_WEAPON_SLOT")
	values = _setup_values()
	template = _setup_template()


# TODO: how to get correct initial values?
func _setup_values() -> Dictionary:
	var vals := {
		COMBAT_RESOURCES: {}
	}

	for t in CombatResource.get_all_types():
		vals[COMBAT_RESOURCES][t] = {
			CURRENT: 100,
			MAX: 100
		}

	vals[CURRENT_WEAPON_SLOT] = 1

	return vals


## types are hardcoded for now
func _setup_template():
	var t := ""
	for row in ["Health", "Energy", "Small Ammo", "Big Ammo"]:
		t = t + "{row}: %d / %d\n".format({"row": row})
	t = t + "Current Weapon: %d"
	return t


## Update text
func _process(_delta: float) -> void:
	var format_vals := []
	for t in CombatResource.get_all_types():
		format_vals.append(values[COMBAT_RESOURCES][t][CURRENT])
		format_vals.append(values[COMBAT_RESOURCES][t][MAX])
	format_vals.append(values[CURRENT_WEAPON_SLOT])
	label.text = template % format_vals


# ----------
# methods triggered by events
# ----------


func update_resource_value(msg: Dictionary):
	var sub_val: Dictionary = values[COMBAT_RESOURCES][msg[TYPE]]
	sub_val[CURRENT] = msg[VALUE] # TODO use one format/key?
	sub_val[MAX] = msg[MAX]


func update_CURRENT_WEAPON_SLOT(msg: Dictionary):
	# TODO use one format/key?
	values[CURRENT_WEAPON_SLOT] = msg[NEW_WEAPON_SLOT] + 1 # plus one for readability
