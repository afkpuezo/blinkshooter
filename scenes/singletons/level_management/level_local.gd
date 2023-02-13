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
export var are_lock_icons_enabled := true


# this won't happen while the game is paused
func _process(_delta: float) -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED


func _ready() -> void:
	LevelGlobal.level_scene_path = level_scene_path
	LevelGlobal.enabled_loot_types = enabled_loot_types
	LevelGlobal.drop_chance_multiplier = drop_chance_multiplier
	LevelGlobal.are_lock_icons_enabled = are_lock_icons_enabled

	PauseManager.is_pausable = true


## called from signal in first level
func enable_lock_icons():
	are_lock_icons_enabled = true
	LevelGlobal.are_lock_icons_enabled = true
