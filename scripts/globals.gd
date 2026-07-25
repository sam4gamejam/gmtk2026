extends Node

const tilesize = Vector2(16, 16)
const screensize = Vector2(320, 180)
const transition_time = 1.5

@onready var tree := get_tree()
@onready var player := tree.get_nodes_in_group("player")[0]
@onready var world = get_node("/root/World")
@onready var screen_fader = world.get_node("ScreenFader")
@onready var rect_fader = screen_fader.get_node("ColorRect")

func make_local_tween(alpha: float) -> Tween:
	var tween := create_tween()
	tween.tween_property(rect_fader, "modulate:a", alpha, transition_time/2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	return tween

func do_screen_transition(current_level: Node2D, next_level_scene: String, color: Color = Color.BLACK) -> void:
	player.can_move = false
	player.process_mode = Node.PROCESS_MODE_DISABLED

	screen_fader.visible = true
	rect_fader.color = color
	rect_fader.modulate.a = 0.0

	await make_local_tween(1.0).finished # Fade out
	world.change_level(current_level, next_level_scene)
	await make_local_tween(0.0).finished # Fade in

	rect_fader.modulate.a = 1.0
	screen_fader.visible = false

	player.can_move = true
	player.process_mode = Node.PROCESS_MODE_INHERIT
