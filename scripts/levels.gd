extends Node2D

@export_file("*.tscn") var next_level_scene: String
@export var music: AudioStream
## Number of moves the player is allowed to do, -1 for no limit
@export var allowed_moves: int = -1
##If true, the player will move between tiles in case of collision
@export var half_tile_movement_allowed: bool = true

@onready var area_next_level := $NextLevel
@onready var environment := $Environment
@onready var player := get_tree().get_nodes_in_group("player")[0]
@onready var world := get_node("/root/World")

func _ready() -> void:
	area_next_level.body_entered.connect(to_next_level, CONNECT_DEFERRED | CONNECT_ONE_SHOT)
	area_next_level.position = area_next_level.position.snapped(Globals.tilesize)

	#tack_items_to_grid()

func tack_items_to_grid() -> void:
	for object in environment.get_children():
		print('before ', object.position)
		object.position = object.position.snapped(Globals.tilesize)
		print('after ', object.position)

func to_next_level(body: Node2D) -> void:
	if body == player:
		Globals.do_screen_transition(self, next_level_scene)
