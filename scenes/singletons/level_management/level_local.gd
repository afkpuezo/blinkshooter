extends Node2D
class_name LevelLocal
## The root node in each level should be one of these, and will update the
## LevelGlobal singleton with data about this level


export var level_scene_path: String
export var enabled_loot_types := {
	Pickup.TYPE.HEALTH: true,
	Pickup.TYPE.ENERGY: true,
	Pickup.TYPE.BASIC_AMMO: true,
	Pickup.TYPE.PLASMA_AMMO: true,
}
export var drop_chance_multiplier := 1.0


func _ready() -> void:
	LevelGlobal.level_scene_path = level_scene_path
	LevelGlobal.enabled_loot_types = enabled_loot_types
	LevelGlobal.drop_chance_multiplier = drop_chance_multiplier
	PauseManager.is_pausable = true
