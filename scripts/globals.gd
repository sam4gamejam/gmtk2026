extends Node

const tilesize = Vector2(16, 16)
const screensize = Vector2(320, 180)
const transition_time = 1.5

@onready var tree := get_tree()

func do_screen_transition() -> void:
	print('before timer transition')
	await tree.create_timer(transition_time).timeout
	print('after timer transition')
