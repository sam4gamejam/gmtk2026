extends Node2D

@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var first_level = $LevelHub
@onready var player := get_tree().get_nodes_in_group("player")[0]

func _ready() -> void:
	change_music(first_level.music)

func _process(delta: float) -> void:
	if Input.is_action_pressed("exit"):
		get_tree().quit()

func change_music(stream: AudioStream, from_position: float = 0.0) -> void:
	audio_player.stream = stream
	audio_player.play(from_position)

func change_level(current_level: Node2D, next_level_scene: String) -> void:
	var next_level: Node2D = load(next_level_scene).instantiate()

	#add_child(next_level)
	add_child.call_deferred(next_level)
	current_level.queue_free()

	##pass next_level.music.position or some such to continue the next track at the same position as the second argument
	change_music(next_level.music)

	## This could be a signal, but the world needs to change first, so I just put it as a function for now
	player.level_changed(next_level)
