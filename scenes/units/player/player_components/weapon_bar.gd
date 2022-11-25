extends ActionBar
class_name WeaponBar
## Holds a set of weapons for the player
## Keeps track of the currently selected weapon, and fires it when the fire button is pressed


var current_slot := 0

export var select_template := "weapon_select_%d"
export var weapon_shoot_event := "weapon_shoot"

var is_firing = false


# ----------
# overriding from ActionBar
# ----------


## making this a function makes it override-able i guess?
static func get_event_signal_string() -> String:
	return "player_weapon_bar_tick"


func setup_events():
	for n in range(0, num_slots):
		monitored_events[select_template % (n + 1)] = n


func add_weapon(w):
	add_action(w)


func handle_event(event: InputEvent) -> void:
	# if shooting
	if event.is_action_pressed(weapon_shoot_event):
		is_firing = true
	elif event.is_action_released(weapon_shoot_event):
		is_firing = false
	# if selecting a slot
	var slot_num = 0
	for weapon_select_event in monitored_events:
		if event.is_action_pressed(weapon_select_event):
			# warning-ignore:return_value_discarded
			_change_slot(slot_num)
			return
		slot_num += 1


## triggers the currently selected weapon if the button is held
func during_process():
	if is_firing:
		if actions.size() == 0:
			pass
		elif current_slot >= actions.size():
			pass
		else:
			var current_weapon: Weapon = actions[current_slot]
			if current_weapon != null:
				trigger_action(current_slot)


## Adds an extra field ('is_current_slot') to the message including whether or
## not the weapon is the currently selected
func emit_update_tick_help(action_index: int) -> Dictionary:
	var sub := .emit_update_tick_help(action_index)
	sub['is_current_slot'] = action_index == current_slot
	return sub


# ----------
# new to WeaponBar
# ----------


## if the given slot number is valid, change the current slot to it
## returns true if actually changed
func _change_slot(slot_num: int) -> bool:
	if slot_num < 0 or slot_num > num_slots:
		return false
	else:
		current_slot = slot_num
		return true


