extends Node
# singleton
## globally-accessible location for data about the current level.
## set by the current level's LevelLocal object.


var level_scene_path : String
var enabled_loot_types: Dictionary
var drop_chance_multiplier: float
var are_lock_icons_enabled: bool setget set_are_lock_icons_enabled


func is_loot_type_enabled(type: int) -> bool:
	return type in enabled_loot_types and enabled_loot_types[type] == true


## this is all probably too much but hey
func set_are_lock_icons_enabled(new_val: bool):
	are_lock_icons_enabled = new_val
	GameEvents.emit_signal(
		"are_lock_icons_enabled_changed",
		{'enabled': are_lock_icons_enabled}
	)
