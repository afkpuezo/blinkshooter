extends Node2D
class_name WeaponBar
## Holds a set of weapons for the player
## Keeps track of the currently selected weapon, and fires it when the fire button is pressed
## NOTE: should this be related to the action bar?
## NOTE: currently doesn't have a way to
## NOTE: I'm once again noticing a lot of overlap with the action bar


# msg args: "old_weapon_slot", "new_weapon_slot"
signal weapon_changed(msg)


onready var user := get_parent() # gross
var weapons: Array # seems better than constatly calling get_child
var current_slot := 0

export var num_slots := 3 # There's probably a better way to set this up
var weapon_select_events := {}

export var select_template := "weapon_select_%d"
export var weapon_shoot_event := "weapon_shoot"

var is_firing = false

func _ready() -> void:
	# set up weapon selects
	for n in range(0, num_slots):
		weapons.append(null)
		weapon_select_events[select_template % (n + 1)] = n
	# set up weapons
	for weapon in get_children():
		add_weapon(weapon, true)


func add_weapon(new_weapon, is_already_child = false):
	var first_empty_slot := -1

	# do we already have this kind of weapon?
	for x in range(num_slots):
		var existing_weapon = weapons[x]
		if existing_weapon == null:
			if first_empty_slot == -1:
				first_empty_slot = x
		elif existing_weapon.name == new_weapon.name:
			return # maybe handle this differently?

	var added := false

	# can it go in its default slot?
	if new_weapon.has_method("get_default_slot"):
		var default_slot = new_weapon.get_default_slot()
		if 0 <= default_slot and default_slot < num_slots and weapons[default_slot] == null:
			weapons[default_slot] = new_weapon
			added = true

	# if it couldn't go in the default slot, put it in the first empty slot
	if not added:
		if first_empty_slot != -1:
			weapons[first_empty_slot] = new_weapon
			added = true
		else:
			print("DEBUG: no room for weapon")
			return

	# setup
	if not is_already_child:
		add_child(new_weapon)
	if new_weapon.has_method("configure_user"):
		new_weapon.configure_user(user)


## triggers the currently selected weapon if the button is held
func _process(_delta: float) -> void:
	if is_firing:
		if weapons.size() == 0:
			#print("DEBUG: WeaponBar._process() not firing due to not having any weapons")
			pass
		elif current_slot >= weapons.size():
			#print("DEBUG: WeaponBar._process() not firing due to current_slot being out of bounds (%d of %d)" % [current_slot, weapons.size()])
			pass
		else:
			var current_weapon: Weapon = weapons[current_slot]
			# warning-ignore:return_value_discarded
			current_weapon.trigger() # TODO: do something with result?


## handles selecting current gun AND shooting
func _unhandled_input(event: InputEvent) -> void:
	# if shooting
	if event.is_action_pressed(weapon_shoot_event):
		is_firing = true
	elif event.is_action_released(weapon_shoot_event):
		is_firing = false
	# if selecting a slot
	var slot_num = 0
	for wse in weapon_select_events:
		if event.is_action_pressed(wse):
			# warning-ignore:return_value_discarded
			_change_slot(slot_num)
			return
		slot_num += 1


## if the given slot number is valid, change the current slot to it
## returns true if actually changed
## NOTE: placeholder
func _change_slot(slot_num: int) -> bool:
	if slot_num < 0 or slot_num > num_slots:
		return false
	else:
		var msg_args = {
				"old_weapon_slot": current_slot,
				"new_weapon_slot": slot_num,
			}
		emit_signal("weapon_changed", msg_args)
		GameEvents.emit_signal("player_changed_weapon", msg_args)
		current_slot = slot_num
		return true


