extends HBoxContainer
class_name ActionUIContainer
## an attempt to rewrite the ActionUIPanel, using built in UI stuff
## This scene manages the UI tiles for one type of action - Actions or Weapons


# these should be set before _ready
export var is_weapon_bar = false # what type is monitored, as opposed to just actions

var tiles := []
export var tile_scale_factor := 1.0
var should_update_tile_order := false

# these are only used when covering weapons
export var current_weapon_scale_factor := 1.10
onready var revert_current_weapon_scale_factor := 1.0 / current_weapon_scale_factor
var current_weapon_index := 0

export var action_event := "player_action_bar_tick"
export var weapon_event := "player_weapon_bar_tick"

export(Array) var hotkeys = ["z", "x", "c", "v", "b"] # better way to get this?

export(PackedScene) var tile_scene


func _ready() -> void:
	# warning-ignore:return_value_discarded
	GameEvents.connect(
		weapon_event if is_weapon_bar else action_event,
		self,
		"on_tick"
	)


## updates tiles based on message from the ActionBar
## if there is a new type, the tile placement will be re-calculated
## (assumes the relative order of existing actions will be maintained)
## msg format: 'actions': array of dictionaries, each dictionary has these fields:
##		name, cooldown_remaining, is_ready, was_triggered_this_frame
func on_tick(msg):
	var tile_index := 0
	var actions: Array = msg['actions']

	for action_index in range(len(actions)):
		var action_dict: Dictionary = actions[action_index]

		if action_dict['name'] == "empty":
			continue

		var tile: ActionUITile = tiles[tile_index] if tile_index < len(tiles) else null

		if tile == null or tile.type != action_dict['name']:
			tile = make_new_tile(action_dict['name'], tile_index, action_index)
			should_update_tile_order = true

		# this part happens whether or not the tile is new
		tile.set_cooldown(action_dict['cooldown_remaining'])
		tile.set_is_ready(action_dict['is_ready'])

		if is_weapon_bar:
			tile.set_current_slot(action_dict['is_current_slot'])
			tile.set_ammo_amount(action_dict['ammo_amount'])
		else:
			tile.set_was_triggered(action_dict['was_triggered_this_frame'])

		# clamping index makes sure that insert works
		tile_index += 1
		tile_index = int(min(tile_index, len(tiles)))
	# end for action_index
	if should_update_tile_order:
		update_tile_order()
		should_update_tile_order = false


## takes care of adding the tile as a child and in the array var
## action_index controls the hotkey label
func make_new_tile(type: String, tile_index: int, action_index: int) -> ActionUITile:
	var tile = tile_scene.instance()
	add_child(tile)

	if is_weapon_bar:
		tile.set_hotkey(action_index + 1)
	else:
		tile.set_hotkey(hotkeys[action_index])

	tile.set_type(type)
	tile.set_min_size_scale_factor(tile_scale_factor) # TODO
	tiles.insert(tile_index, tile)
	return tile


## I think the only way to update the order in a container is to remove the
## tiles as children and then re-add them
func update_tile_order():
	for tile in tiles:
		remove_child(tile)
	for tile in tiles:
		add_child(tile)

