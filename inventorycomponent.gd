class_name InventoryComponent
extends Node

var inventory_size: Vector2i = Vector2i(5, 5)

enum ExploreState { NOT_EXPLORED, EXPLORING, EXPLORED }
var explore_state: ExploreState = ExploreState.NOT_EXPLORED

var items: Array[Item]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
