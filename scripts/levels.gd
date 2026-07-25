extends Node2D

@export_file("*.tscn") var next_level_scene: String
@export var music: AudioStream

@onready var area_next_level := $NextLevel
@onready var player := get_tree().get_nodes_in_group("player")[0]
@onready var world := get_node("/root/World")

func _ready() -> void:
	area_next_level.body_entered.connect(to_next_level, CONNECT_DEFERRED | CONNECT_ONE_SHOT)
	area_next_level.position = area_next_level.position.snapped(Globals.tilesize)

func to_next_level(body: Node2D) -> void:
	if body == player:
		Globals.do_screen_transition(self, next_level_scene)
