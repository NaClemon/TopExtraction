class_name MovementComponent
extends Node

@export var speed: float = 100.0

enum State { IDLE, WALK, RUN }

var current_state: State = State.IDLE:
	set(value):
		if current_state != value:
			current_state = value


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
