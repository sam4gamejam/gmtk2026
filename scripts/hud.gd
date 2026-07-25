extends CanvasLayer

@onready var label := $Label
@onready var player := get_tree().get_nodes_in_group("player")[0]
@onready var world := get_node("/root/World")

var basetext: String = 'Number of moves used: %s out of %s total moves'

func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	label.text = basetext % [str(Globals.current_number_of_moves), str(Globals.max_number_of_moves)]

func _draw() -> void:
	pass
