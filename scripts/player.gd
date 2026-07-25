extends CharacterBody2D

signal player_picked_tile
signal tile_moved(tile: PickableTile)

@onready var can_move: bool = true
@onready var half_tile_movement_allowed: bool = true
@onready var tile_is_already_picked: bool = false

@onready var move_timer := $MoveCooldownTimer
@onready var sprite := $AnimatedSprite2D
@onready var world = get_node("/root/World")

var previous_vec_quadrant: Vector2 = Vector2.ZERO
var layer: InteractableLayer
var tile: PickableTile

func _ready() -> void:
	#snap_player_to_grid()

	move_timer.timeout.connect(move_timer_completed)
	player_picked_tile.connect(on_tile_picked)
	tile_moved.connect(self.tile_just_moved)

func _process(_delta: float) -> void:
	if not can_move:
		return

	if Input.is_action_just_pressed("pick_tile"):
		player_picked_tile.emit()
		return

	var movedir := Input.get_vector("left", "right", "up", "down")

	# Only allow one keypress, we could choose one direction instead of stopping
	if movedir.length() != 1:
		return

	var current_move_body = tile if tile_is_already_picked else self
	var just_moved: bool = move_object(current_move_body, movedir)

	if just_moved:
		if current_move_body == self:
			change_player_sprite(movedir)
		else:
			tile_moved.emit(tile)

func change_player_sprite(movedir: Vector2) -> void:
	match movedir:
		Vector2.LEFT:
			sprite.animation = 'left'
		Vector2.RIGHT:
			sprite.animation = 'right'
		Vector2.DOWN:
			sprite.animation = 'down'
		Vector2.UP:
			sprite.animation = 'up'

func level_changed(new_level: Node2D) -> void:
	# If we change the level, disconnect then reconnect the tile signal to the new level just in case
	if layer != null and tile_moved.is_connected(layer.tile_just_moved):
		tile_moved.disconnect(layer.tile_just_moved)

	layer = new_level.get_node("Environment/InteractableLayer")
	tile_moved.connect(layer.tile_just_moved)
	half_tile_movement_allowed = new_level.half_tile_movement_allowed
	snap_player_to_grid(new_level)

func move_object(body, movedir: Vector2) -> bool:
	var move_vec := movedir * Globals.tilesize
	var new_position = body.position + move_vec
	new_position = new_position.clamp(Vector2.ZERO, Globals.screensize - Globals.tilesize)

	# We check a new position to see if we moved, since we can bump into a wall or tile
	if body.position == new_position:
		return false

	can_move = false
	move_timer.start()

	if body == self:
		var move_is_invalid = test_move(transform, move_vec)
		if move_is_invalid and !half_tile_movement_allowed:
			print('would have moved into obstacle')
			return false
		else:
			# Cut collision by half until it fits
			var breakout = false
			while move_is_invalid:
				move_vec /= 2
				move_is_invalid = test_move(transform, move_vec)
				breakout = true

			#TODO: Weird bug if we come from negative coordinate, so halve it again to see if it works better
			if breakout and move_vec < Vector2.ZERO:
				move_vec *= 2

			new_position = body.position + move_vec
			new_position = new_position.clamp(Vector2.ZERO, Globals.screensize - Globals.tilesize)

	## has to be snapped to tilesize/2 because we also move the tiles in this function,
	## and somehow they will be offset by half if we snap to tilesize...
	body.position = new_position.snapped(Globals.tilesize/2)
	return true

func move_timer_completed() -> void:
	can_move = true
	move_timer.stop()

func increment_tile_moved_counter() -> void:
	Globals.current_number_of_moves += 1
	if Globals.max_number_of_moves == -1:
		return

	if Globals.current_number_of_moves > Globals.max_number_of_moves:
		print('Total moves went over!')
		print(Globals.current_number_of_moves, Globals.max_number_of_moves)
		Globals.current_number_of_moves = 0

func on_tile_picked() -> void:
	if tile_is_already_picked:
		if !layer.place_tile_at(tile.global_position, tile):
			return
		tile = null
		increment_tile_moved_counter()
	else:
		tile = layer.pick_tile_at(global_position)
		if tile == null:
			return
		layer.change_tile_color(tile, layer.color_ok_here)

	tile_is_already_picked = !tile_is_already_picked

func snap_player_to_grid(new_level: Node2D) -> void:
	if !new_level.has_node("Spawner"):
		return

	var spawner = new_level.get_node("Spawner")
	position = spawner.position.snapped(Globals.tilesize)

func tile_just_moved(current_tile: PickableTile) -> void:
	var angle: float = (current_tile.global_position - global_position).angle()
	var quadrant: float = snappedf(angle, PI/4)
	var vec_quadrant: Vector2 = Vector2(cos(quadrant), sin(quadrant))

	if previous_vec_quadrant == vec_quadrant:
		return

	previous_vec_quadrant = vec_quadrant
	change_player_sprite(vec_quadrant)
