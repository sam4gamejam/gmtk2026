class_name InteractableLayer
extends TileMapLayer

@export_range(0, 1, 0.05) var alpha_blend: float = 0.5
@export var color_ok_here: Color = Color.SEA_GREEN
@export var color_not_ok_here: Color = Color.DARK_RED
@export var pickable_item_scene: PackedScene

func change_tile_color(tile: PickableTile, color: Color) -> void:
	var new_color = color
	new_color.a = alpha_blend
	tile.modulate = new_color

func is_tile_pickable(global_pos: Vector2) -> bool:
	var map_coords = local_to_map(global_pos)
	var tile_data = get_cell_tile_data(map_coords)
	if tile_data:
		return tile_data.get_custom_data("pickable")
	return false

func is_cell_empty(global_pos: Vector2) -> bool:
	var map_coords = local_to_map(global_pos)
	return get_cell_source_id(map_coords) == -1

func pick_tile_at(global_pos: Vector2) -> PickableTile:
	var map_coords = local_to_map(global_pos)

	if not is_tile_pickable(global_pos):
		return null

	var source_id = get_cell_source_id(map_coords)
	var atlas_coords = get_cell_atlas_coords(map_coords)

	var tile_source : TileSetAtlasSource = tile_set.get_source(source_id)
	var texture = tile_source.texture
	var region = tile_source.get_tile_texture_region(atlas_coords)

	set_cell(map_coords, -1)

	if pickable_item_scene:
		var item_instance : PickableTile = pickable_item_scene.instantiate()
		get_parent().add_child(item_instance)

		var cell_world_pos = map_to_local(map_coords)
		item_instance.global_position = to_global(cell_world_pos)

		item_instance.setup(texture, region, source_id, atlas_coords)
		item_instance.z_index += 1

		return item_instance

	return null

func place_tile_at(global_pos: Vector2, item: PickableTile) -> bool:
	if not is_cell_empty(global_pos):
		return false

	var map_coords = local_to_map(global_pos)
	set_cell(map_coords, item.source_id, item.atlas_coords)
	item.queue_free()
	return true

func tile_just_moved(tile: PickableTile) -> void:
	var new_color = color_ok_here if is_cell_empty(tile.global_position) else color_not_ok_here
	change_tile_color(tile, new_color)
	print('tile moved', global_position, tile.global_position)
