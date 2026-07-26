extends "res://scripts/levels.gd"

@onready var area_end := $"End"
@onready var end_level: String = "scenes/end.tscn"

@export var car_start: AudioStream
@export var car_accelerate: AudioStream
@export var fade_end_color: Color = Color.NAVY_BLUE

func _ready() -> void:
	area_end.body_entered.connect(to_end, CONNECT_DEFERRED)
	print('in custom ready')

func to_end(body: Node2D) -> void:
	print('in end level')
	if body != player:
		return

	player.visible = false
	player.set_process(false)
	player.set_physics_process(false)

	await Globals.play_sfx(car_start, true)
	Globals.play_sfx(car_accelerate)

	var parking := get_parent()
	Globals.fade_ending(fade_end_color, end_level)
