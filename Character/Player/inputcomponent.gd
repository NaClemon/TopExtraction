class_name InputComponent
extends MovementComponent

signal move_action

# { "action_name": Callable } 형태의 딕셔너리
var input_action_map: Dictionary = {}
func bind_action(action_name: String, callback: Callable):
	input_action_map[action_name] = callback

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _physics_process(delta: float) -> void:
	var input_vector := Vector2.ZERO
	
	if Input.is_action_pressed("move_up"):
		input_vector.y -= 1
	if Input.is_action_pressed("move_down"):
		input_vector.y += 1
	if Input.is_action_pressed("move_right"):
		input_vector.x += 1
	if Input.is_action_pressed("move_left"):
		input_vector.x -= 1
		
	## Fallback to UI actions (Arrow keys) if WASD is not pressed
	#if input_vector == Vector2.ZERO:
		#input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		#input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
		#
	#if input_vector.length() > 0:
		#input_vector = input_vector.normalized()
	#elif is_touching and touch_vector.length() > 0:
		## Use mobile drag/swipe input if keyboard/UI is idle
		#input_vector = touch_vector
		#
	
	move_action.emit(input_vector * speed)

func _input(event: InputEvent) -> void:
	for input_action in input_action_map:
		if event.is_action_pressed(input_action):
			input_action_map[input_action].call()
		
