class_name Item
extends Node

@export var item_name: String = "New Item"
@export var icon: Texture2D
@export var width: int = 1 # 가로 차지 칸 수
@export var height: int = 1 # 세로 차지 칸 수

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
