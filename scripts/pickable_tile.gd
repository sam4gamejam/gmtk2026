class_name PickableTile
extends Node2D

@onready var sprite: Sprite2D = $Sprite2D

var source_id: int = -1
var atlas_coords: Vector2i = Vector2i(-1, -1)

func setup(texture: Texture2D, region: Rect2, p_source_id: int, p_atlas_coords: Vector2i) -> void:
	sprite.texture = texture
	sprite.region_enabled = true
	sprite.region_rect = region
	source_id = p_source_id
	atlas_coords = p_atlas_coords
