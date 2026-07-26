extends Node2D

@export_file("*.tscn") var next_level_scene: String
@export var music: AudioStream
## Number of moves the player is allowed to do, -1 for no limit
@export var allowed_moves: int = -1
##If true, the player will move between tiles in case of collision
@export var half_tile_movement_allowed: bool = true
@export var sprite: String = "Hotel"

@onready var area_next_level := $NextLevel
@onready var environment := $Environment
@onready var collision_next_level: CollisionShape2D = area_next_level.get_node("CollisionShape2D")
@onready var is_goal_completed: bool = false

@onready var player := get_tree().get_nodes_in_group("player")[0]
@onready var world := get_node("/root/World")

func _ready() -> void:
	area_next_level.body_entered.connect(to_next_level, CONNECT_DEFERRED | CONNECT_ONE_SHOT)
	#area_next_level.position = area_next_level.position.snapped(Globals.tilesize)
	Globals.do_reset_level.connect(reset_level)

	# If we are in a funky world, disable the next level area until goal is complete
	var to_disable = ["FrontDesk","Depths", "Chessboard"] # "Forest"
	if self.name in to_disable:
		print('disabling exit until goal!')
		collision_next_level.set_deferred("disabled", true)
		if self.name == "Chessboard":
			if has_node("UndergroundElevator"):
				$UndergroundElevator/AnimatedSprite2D.play("MinusTwo")
		if player:
			player.tile_moved.connect(_on_tile_moved)
	#tack_items_to_grid()

func _on_tile_moved(moved_tile: PickableTile) -> void:
	if is_goal_completed or not has_node("Environment/GoalDetector"):
		return
	var interactable_layer = $Environment/InteractableLayer
	var goal_marker = $Environment/GoalDetector
	var target_cell = interactable_layer.local_to_map(interactable_layer.to_local(goal_marker.global_position))
	var tile_cell = interactable_layer.local_to_map(interactable_layer.to_local(moved_tile.global_position))
	if tile_cell == target_cell:
		is_goal_completed = true
		goal_achieved()

func goal_achieved() -> void:
	Globals.play_sfx(world.elevator_open)
	collision_next_level.set_deferred("disabled", false)
	match self.name:
		"FrontDesk":
			$BaseElevator/AnimatedSprite2D.play("Opening")
		"Depths":
			pass
		"Chessboard":
			pass
		_:
			pass

func reset_level(color: Color = Color.CRIMSON) -> void:
	Globals.do_screen_transition(self, self.get_scene_file_path(), color)

func tack_items_to_grid() -> void:
	for object in environment.get_children():
		print('before ', object.position)
		object.position = object.position.snapped(Globals.tilesize)
		print('after ', object.position)

func to_next_level(body: Node2D) -> void:
	if body == player:
		Globals.do_screen_transition(self, next_level_scene)
