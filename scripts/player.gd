extends Node2D

signal player_picked_tile 

## Time in seconds before allowing player movement, should be animation length
@export var move_cooldown: float = 0.35

@onready var tile_is_picked: bool = false
@onready var can_move: bool = true
@onready var move_timer: float = 0.0

@onready var crosshair := $Crosshair
@onready var sprite := $AnimatedSprite2D

func _ready() -> void:
	position = position.snapped(Globals.tilesize)
	player_picked_tile.connect(on_tile_picked)

func _process(delta: float) -> void:
	if Input.is_action_pressed("pick_tile"):
		player_picked_tile.emit()
			
	move_timer += delta
	
	if move_timer >= move_cooldown:
		can_move = true 
	
	if not can_move:
		return 
		
	var movedir := Input.get_vector("left", "right", "up", "down")
	
	# Only allow one keypress, we could choose one direction instead of stopping
	if movedir.length() != 1:
		return
		
	#position = position.snapped(Globals.tilesize * movedir)
	var new_position = (position + movedir * Globals.tilesize).clamp(Globals.tilesize/2, Globals.screensize - Globals.tilesize)
	
	# We check a new position to see if we moved, since we can bump into a wall or tile
	if position == new_position:
		return 
		
	can_move = false
	move_timer = 0.0
	position = new_position.snapped(Globals.tilesize)
	
	change_sprite_facing(movedir)
	
func change_sprite_facing(movedir: Vector2) -> void:
	match movedir:
		Vector2.LEFT:
			sprite.animation = 'left'
		Vector2.RIGHT:
			sprite.animation = 'right'
		Vector2.DOWN:
			sprite.animation = 'down'
		Vector2.UP:
			sprite.animation = 'up'	

func on_tile_picked() -> void:
	if tile_is_picked:
		crosshair.visible = true 
		drop_tile()
	else:
		crosshair.visible = false
				
	tile_is_picked = !tile_is_picked
	
func drop_tile():
	pass
