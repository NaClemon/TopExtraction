extends CharacterBody2D

@export var speed: float = 400.0
@export var radius: float = 30.0
@export var color: Color = Color(0.2, 0.6, 1.0) # Sleek blue

func _ready() -> void:
	# Queue redraw to draw the circle
	queue_redraw()
	
	# Update collision shape to match the radius
	var collision_shape = get_node_or_null("CollisionShape2D")
	if collision_shape and collision_shape.shape is CircleShape2D:
		collision_shape.shape.radius = radius

func _draw() -> void:
	# Draw a smooth anti-aliased circle
	draw_circle(Vector2.ZERO, radius, color)
	# Draw a white outline for a premium look
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 64, Color(1.0, 1.0, 1.0), 2.0, true)

func _physics_process(_delta: float) -> void:
	var input_vector := Vector2.ZERO
	
	# Detect WASD keys
	if Input.is_key_pressed(KEY_W):
		input_vector.y -= 1
	if Input.is_key_pressed(KEY_S):
		input_vector.y += 1
	if Input.is_key_pressed(KEY_A):
		input_vector.x -= 1
	if Input.is_key_pressed(KEY_D):
		input_vector.x += 1
		
	# Fallback to UI actions (Arrow keys) if WASD is not pressed
	if input_vector == Vector2.ZERO:
		input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
		
	if input_vector.length() > 0:
		input_vector = input_vector.normalized()
		
	velocity = input_vector * speed
	move_and_slide()

	# Clamp position to screen bounds
	var viewport_rect := get_viewport_rect()
	if viewport_rect:
		position.x = clamp(position.x, radius, viewport_rect.size.x - radius)
		position.y = clamp(position.y, radius, viewport_rect.size.y - radius)
