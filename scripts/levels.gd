extends Node2D

@export var next_level: PackedScene
@export var music: AudioStream

@onready var area_next_level = $NextLevel
@onready var world = get_node("/root/World")

func _ready() -> void:
	area_next_level.position = area_next_level.position.snapped(Globals.tilesize)
	area_next_level.area_entered.connect(to_next_level)

func to_next_level() -> void:
	world.change_level(self, next_level)
	Globals.do_screen_transition()
