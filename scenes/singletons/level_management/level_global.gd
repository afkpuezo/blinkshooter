extends Node
# singleton
## globally-accessible location for data about the current level.
## set by the current level's LevelLocal object.


var level_scene_path : String
var enabled_loot_types: Dictionary
var drop_chance_multiplier: float


func is_loot_type_enabled(type: int) -> bool:
	return type in enabled_loot_types and enabled_loot_types[type] == true
