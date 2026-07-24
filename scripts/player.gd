extends Node2D

signal player_picked_tile(tile: PickableTile)

@onready var can_move: bool = true
@onready var tile_is_already_picked: bool = false

@onready var crosshair := $Crosshair
@onready var layer := $"../InteractableLayer"
@onready var move_timer := $MoveCooldownTimer
@onready var sprite := $AnimatedSprite2D

var tile: PickableTile

func _ready() -> void:
	position = position.snapped(Globals.tilesize)

	player_picked_tile.connect(on_tile_picked)
	move_timer.timeout.connect(move_timer_completed)

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

	if current_move_body == self and just_moved:
		change_player_sprite(movedir)

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

func move_object(body, movedir: Vector2) -> bool:
	#position = position.snapped(Globals.tilesize * movedir)
	var new_position = (body.position + movedir * Globals.tilesize).clamp(Globals.tilesize/2, Globals.screensize - Globals.tilesize)

	# We check a new position to see if we moved, since we can bump into a wall or tile
	if body.position == new_position:
		return false

	can_move = false
	move_timer.start()
	body.position = new_position.snapped(Globals.tilesize)
	return true

func move_timer_completed() -> void:
	can_move = true
	move_timer.stop()

func on_tile_picked() -> void:
	print('tile picked signal emitted!')
	if tile_is_already_picked:
		print('currently hovering tile')
		if !layer.place_tile_at(tile.global_position, tile):
			#TODO: Make crosshair red to indicate this spot is no good
			return
		crosshair.visible = false
		tile = null
	else:
		print('just picked a tile')
		tile = layer.pick_tile_at(global_position)
		if tile == null:
			return
		crosshair.visible = true
	tile_is_already_picked = !tile_is_already_picked
