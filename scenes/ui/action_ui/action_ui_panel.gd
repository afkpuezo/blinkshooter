extends Control
class_name ActionUIPanel
## This scene manages the UI tiles for one type of action - Actions or Weapons

# these should be set before _ready
var is_action = true # what type is monitored, as opposed to weapon
var center_justified = true # as opposed to left justified

var tiles := []
export var tile_spacing := 92 # measured between the CENTER of each tile

export var action_event := "player_action_bar_tick"
export var weapon_event := "player_weapon_bar_tick"

export(Array) var hotkeys = ["z", "x", "c", "v", "b"] # better way to get this?

export(PackedScene) var tile_scene


func _ready() -> void:
	GameEvents.connect(
		action_event if is_action else weapon_event,
		self,
		"on_tick"
	)


## updates tiles based on message from the ActionBar
## if there is a new type, the tile placement will be re-calculated
## (assumes the relative order of existing actions will be maintained)
## msg format: 'actions': array of dictionaries, each dictionary has these fields:
##		name, cooldown_remaining, can_trigger, was_triggered_this_frame
func on_tick(msg):
	var tile_index := 0
	var actions: Array = msg['actions']
	var should_update_placement := false

	for action_index in range(len(actions)):
		var action_dict: Dictionary = actions[action_index]

		if action_dict['name'] == "empty":
			continue

		var tile: ActionUITile = tiles[tile_index] if tile_index < len(tiles) else null

		if tile == null or tile.type != action_dict['name']:
			tile = tile_scene.instance()
			tile.set_type(action_dict['name'])
			should_update_placement = true

			tiles.insert(tile_index, tile)
			tile_index += 1 # account for adding new tile
			add_child(tile)

		# this part happens whether or not the tile is new
		tile.set_cooldown(action_dict['cooldown_remaining'])
		tile.set_can_trigger(action_dict['can_trigger'])
		tile.set_was_triggered(action_dict['was_triggered_this_frame'])

		# clamping index makes sure that insert works
		tile_index += 1
		tile_index = min(tile_index, len(tiles))
	# end for action_index
	if should_update_placement:
		update_tile_placement()


## called when a new tile is added
func update_tile_placement():
	# determine starting position based on justification and number of tiles
	var are_tiles_even = len(tiles) % 2 == 0
	var starting_x = (tile_spacing / -2) if are_tiles_even else 0

	if center_justified:
		pass # TODO CONTINUE HERE
	else:
		pass
