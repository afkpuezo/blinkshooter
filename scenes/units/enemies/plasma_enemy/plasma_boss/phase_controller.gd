extends Node2D
class_name PhaseController
## this hypothetically could be more generic but i'm just going to tailor it
## to the boss. upgrades weapon and movement at hp threshold


export var hp_threshold := 0.5

# values will be changed TO this
export var attack_allows_diag := false
export var weapon_num_bullets := 3
export var weapon_max_degrees := 90
export var rotation_speed_deg := 220

var has_phase_triggered := false


func on_hp_update(new_hp: float, max_hp: int):
	var ratio := new_hp / max_hp

	if ratio <= hp_threshold:
		if has_phase_triggered:
			return

		has_phase_triggered = true
		var brain: EnemyBrain = owner.get_node("EnemyBrain")
		brain.attack_allows_non_center_detection = attack_allows_diag

		# maybe it would have been easier to just make a new weapon lol
		var weapon_bar: EnemyWeaponBar = brain.get_node("EnemyWeaponBar")
		var weapon: Weapon = weapon_bar.remove_all()[0]
		weapon.spawn_location = null
		weapon.user_movement_stats = null
		weapon.angles = []
		weapon.num_bullets = weapon_num_bullets
		weapon.max_angle = deg2rad(weapon_max_degrees)
		weapon.setup_angles()
		owner.disconnect("died", weapon, "on_user_death")

		weapon_bar.add_action(weapon)

		var move_stats := MovementStats.get_movement_stats(owner)
		move_stats.rotation_speed = deg2rad(rotation_speed_deg)

