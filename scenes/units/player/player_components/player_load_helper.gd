extends Node2D
class_name PlayerLoadHelper
## used to give a Player the actions and weapons they're supposed to have at
## the start of a level/zone
## (this is because manually adding these items to the player in the scene means
## the player doesn't get updates from the base player scene)


func _ready() -> void:
	var player: Unit
	var actions := []
	var weapons := []

	for c in get_children():
		if PlayerBrain.is_player(c):
			player = c
		elif Weapon.is_weapon(c):
			weapons.append(c)
		elif Action.is_action(c):
			actions.append(c)

	# NOTE: hardcoded child path might be a problem
	var action_bar: ActionBar = player.get_node("ActionBar")
	var weapon_bar: WeaponBar = player.get_node("WeaponBar")

	for action in actions:
		remove_child(action)
		action_bar.add_action(action)

	for weapon in weapons:
		remove_child(weapon)
		weapon_bar.add_weapon(weapon)

