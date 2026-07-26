extends Node2D

@export var allowed_moves: int = -1
@export var half_tile_movement_allowed: bool = true
@export var sprite: String = "Hotel"

@onready var end_png = $CanvasLayer/Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
