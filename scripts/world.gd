extends Node2D

@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var first_level := $HotelRoom
@onready var player := get_tree().get_nodes_in_group("player")[0]

@export var elevator_close: AudioStream
@export var elevator_open: AudioStream

func _ready() -> void:
	change_music(first_level.music)
	player.level_changed(first_level)

func _process(delta: float) -> void:
	if Input.is_action_pressed("exit"):
		get_tree().quit()

func change_music(stream: AudioStream, from_position: float = 0.0) -> void:
	if stream != null:
		audio_player.stream = stream
		audio_player.play(from_position)

func change_level(level_current: Node2D, next_level_scene: String) -> void:
	var next_level: Node2D = load(next_level_scene).instantiate()

	add_child.call_deferred(next_level)
	level_current.queue_free()

	## pass next_level.music.position or some such to continue the next track
	## at the same position as the second argument
	if "music" in next_level:
		change_music(next_level.music)

	## This could be a signal, but the world needs to change first, so I just put it as a function for now
	player.level_changed(next_level)
	Globals.assign_number_of_moves(next_level.allowed_moves)
	level_current = next_level
	Globals.play_sfx(elevator_close)
