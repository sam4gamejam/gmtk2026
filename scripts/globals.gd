extends Node

signal do_reset_level

const tilesize = Vector2(16, 16)
const screensize = Vector2(320, 180)
const transition_time = 1.5

@onready var tree := get_tree()
@onready var player := tree.get_nodes_in_group("player")[0]
@onready var world = get_node("/root/World")
@onready var screen_fader = world.get_node("ScreenFader")
@onready var rect_fader = screen_fader.get_node("ColorRect")
@onready var sfx_player = world.get_node("SfxPlayer")

var current_number_of_moves: int = 0
var max_number_of_moves: int = -1
var timer_end_screen: float = 4.5

func _ready() -> void:
	pass

func assign_number_of_moves(new_moves: int) -> void:
	current_number_of_moves = 0
	max_number_of_moves = new_moves

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

func fade_intro(color: Color) -> void:
	screen_fader.visible = true
	rect_fader.color = color
	rect_fader.modulate.a = 0.0

	#await make_local_tween(0.0).finished # Fade in
	var tween := create_tween()
	tween.tween_property(rect_fader, "modulate:a", 0.0, 1.5*transition_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await tween.finished

	rect_fader.modulate.a = 1.0
	screen_fader.visible = false

func fade_ending(color: Color, end_level: String) -> void:
	#player.process_mode = Node.PROCESS_MODE_DISABLED

	screen_fader.visible = true
	rect_fader.color = color
	rect_fader.modulate.a = 0.0

	await make_local_tween(1.0).finished # Fade out
	await make_local_tween(0.0).finished # Fade in

	rect_fader.modulate.a = 1.0
	screen_fader.visible = false
	var end_level_node: Node2D = load(end_level).instantiate()
	world.add_child(end_level_node)
	var canvas = end_level_node.get_node("CanvasLayer")

	await tree.create_timer(timer_end_screen).timeout
	tree.quit()

func make_local_tween(alpha: float) -> Tween:
	var tween := create_tween()
	tween.tween_property(rect_fader, "modulate:a", alpha, transition_time/2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	return tween

func increment_tile_moved_counter() -> void:
	Globals.current_number_of_moves += 1
	if Globals.max_number_of_moves == -1:
		return

	if Globals.current_number_of_moves > Globals.max_number_of_moves:
		print('Total moves went over!')
		do_reset_level.emit()
		Globals.current_number_of_moves = 0

func scene2node(scene: String) -> Node:
	return load(scene).instantiate()

func play_sfx(sfx: AudioStream, wait_till_finished: bool = false) -> void:
	sfx_player.stream = sfx
	sfx_player.play()

	if wait_till_finished:
		await sfx_player.finished
