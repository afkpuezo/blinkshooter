extends VBoxContainer
class_name ResourceBarManager
## manages health and energy bars for the PlayerUI

var bars := {}


func _ready() -> void:
	# get signals about changes
	# warning-ignore:return_value_discarded
	GameEvents.connect(
		"player_combat_resource_value_changed",
		self,
		"handle_resource_change"
	)
	# set up bars vars
	bars[CombatResource.Type.HEALTH] = $HealthBar
	bars[CombatResource.Type.ENERGY] = $EnergyBar


func handle_resource_change(args: Dictionary):
	var incoming_type = args['type']
	if incoming_type in bars:
		bars[incoming_type].change_value(
			args['value'],
			args['max']
		)
	else: # if type not in bars
		pass
