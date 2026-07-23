extends Sprite2D

@onready var player := get_tree().get_nodes_in_group("player")[0]

func _ready() -> void:
	player.player_picked_tile.connect(on_tile_picked)
		
func _process(delta: float) -> void:
	pass

func on_tile_picked() -> void:
	pass 
	# This is offset currently, but might not be needed if we use magically hovering tiles anyway
	#position = player.position + Globals.tilesize
