extends Control
class_name ActionUIPanel
## This scene manages the UI tiles for one type of action - Actions or Weapons

# these should be set before _ready
export var is_action = true # what type is monitored, as opposed to weapon
export var center_justified = true # as opposed to left justified

var tiles := []
export var tile_spacing := 92 # measured between the CENTER of each tile
export var tile_scale_factor := 1.0
onready var tile_scale_vector := Vector2(tile_scale_factor, tile_scale_factor)

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
##		name, cooldown_remaining, is_ready, was_triggered_this_frame
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
			should_update_placement = true
			tile = make_new_tile(action_dict['name'])
			tiles.insert(tile_index, tile)

		# this part happens whether or not the tile is new
		tile.set_cooldown(action_dict['cooldown_remaining'])
		tile.set_is_ready(action_dict['is_ready'])
		tile.set_was_triggered(action_dict['was_triggered_this_frame'])

		# clamping index makes sure that insert works
		tile_index += 1
		tile_index = min(tile_index, len(tiles))
	# end for action_index
	if should_update_placement:
		update_tile_placement()


## takes care of adding the tile as a child
func make_new_tile(type: String) -> ActionUITile:
	var tile = tile_scene.instance()
	tile.set_type(type)
	tile.rect_scale = tile_scale_vector
	add_child(tile)
	return tile

## called when a new tile is added
func update_tile_placement():
	# determine starting position based on justification and number of tiles
	var x_step = 0

	if center_justified:
		var are_tiles_even = len(tiles) % 2 == 0
		x_step = (tile_spacing / 2) if are_tiles_even else 0
		x_step += (len(tiles) / -2) * tile_spacing
	else:
		pass # don't change start

	var base_x = rect_position[0]
	for tile in tiles:
		tile.rect_position = Vector2(base_x + x_step, 0)
		x_step += tile_spacing


