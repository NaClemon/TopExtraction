extends CharacterBody2D

@export var vision: VisionComponent
@export var input: InputComponent

@export_group("CharacterBody")
@export var radius: float = 30.0
@export var color: Color = Color(0.2, 0.6, 1.0) # Sleek blue

# Ambient darkness parameters
@export_group("Darkness")
@export var enable_darkness: bool = true
@export var darkness_color: Color = Color.WHITE #Color(0.3, 0.3, 0.3, 1.0)

# Equipment parameters
@export_group("Equipment")
@export var start_weapon_scene: PackedScene = preload("res://Item/Equipment/Weapon/Melee/axe.tscn")
@export var weapon_offset: float = 30.0 # Distance from player center to hold the weapon

# Touch movement parameters
@export var drag_threshold: float = 10.0 # Minimum drag distance to trigger movement (pixels)
@export var max_drag_distance: float = 120.0 # Distance for maximum speed (pixels)

var touch_start_pos := Vector2.ZERO
var touch_current_pos := Vector2.ZERO
var is_touching := false
var touch_vector := Vector2.ZERO
var touch_indicator: Control

var weapon_pivot: Node2D
var equipped_weapon: Weapon

func _ready() -> void:
	create_body()

	# Create a CanvasLayer to overlay the touch joystick indicator on top of the viewport
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100
	add_child(canvas_layer)
	
	touch_indicator = Control.new()
	touch_indicator.anchor_right = 1.0
	touch_indicator.anchor_bottom = 1.0
	touch_indicator.mouse_filter = Control.MOUSE_FILTER_IGNORE
	touch_indicator.draw.connect(_draw_touch_indicator)
	canvas_layer.add_child(touch_indicator)

	# Setup the Weapon Pivot and Default Weapon
	setup_weapon_system()

	# Setup ambient darkness filter
	setup_darkness()
	
	input.bind_action("attack", _on_attack)

func setup_darkness() -> void:
	# Setup darkness filter (CanvasModulate) in the scene
	if enable_darkness:
		var parent = get_parent()
		if parent:
			var existing_modulate = parent.find_child("CanvasModulate", true, false)
			if not existing_modulate:
				var modulate = CanvasModulate.new()
				modulate.name = "CanvasModulate"
				modulate.color = darkness_color
				parent.add_child.call_deferred(modulate)

func _draw() -> void:
	# Create Body
	draw_circle(Vector2.ZERO, radius, color)
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 64, Color(1.0, 1.0, 1.0), 2.0, true)

func create_body() -> void:
	# Redraw character body
	queue_redraw()
	
	# Update collision shape to match the radius
	var collision_shape = get_node_or_null("CollisionShape2D")
	if collision_shape and collision_shape.shape is CircleShape2D:
		collision_shape.shape.radius = radius

func _draw_touch_indicator() -> void:
	if not is_touching:
		return
		
	# Outer joystick base: translucent neon blue ring
	touch_indicator.draw_circle(touch_start_pos, max_drag_distance * 0.5, Color(0.2, 0.6, 1.0, 0.12))
	touch_indicator.draw_arc(touch_start_pos, max_drag_distance * 0.5, 0.0, TAU, 64, Color(0.2, 0.6, 1.0, 0.35), 2.0, true)
	
	# Connecting guide line
	if touch_vector.length() > 0:
		touch_indicator.draw_line(touch_start_pos, touch_current_pos, Color(0.2, 0.6, 1.0, 0.25), 3.0, true)
		
	# Inner joystick handle: premium sleek glowing blue knob
	touch_indicator.draw_circle(touch_current_pos, 20.0, Color(0.2, 0.6, 1.0, 0.75))
	touch_indicator.draw_circle(touch_current_pos, 17.0, Color(1.0, 1.0, 1.0, 0.85))
	touch_indicator.draw_circle(touch_current_pos, 10.0, Color(0.2, 0.6, 1.0, 1.0))

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			is_touching = true
			touch_start_pos = event.position
			touch_current_pos = event.position
			touch_vector = Vector2.ZERO
		else:
			is_touching = false
			touch_vector = Vector2.ZERO
		if touch_indicator:
			touch_indicator.queue_redraw()
			
	elif event is InputEventScreenDrag and is_touching:
		touch_current_pos = event.position
		var raw_vector = touch_current_pos - touch_start_pos
		
		# Check if the drag distance exceeds the threshold
		if raw_vector.length() > drag_threshold:
			var drag_len = min(raw_vector.length(), max_drag_distance)
			# Standardize the drag vector between 0.0 and 1.0 based on distance
			touch_vector = raw_vector.normalized() * (drag_len / max_drag_distance)
		else:
			touch_vector = Vector2.ZERO
			
		if touch_indicator:
			touch_indicator.queue_redraw()


func _physics_process(_delta: float) -> void:
	pass
	## Rotate weapon pivot towards the mouse cursor
	#if weapon_pivot and is_instance_valid(weapon_pivot):
		#var mouse_pos = get_global_mouse_position()
		#var dir = mouse_pos - global_position
		#if dir.length() > 0:
			#weapon_pivot.rotation = dir.angle()

func setup_weapon_system() -> void:
	weapon_pivot = Node2D.new()
	weapon_pivot.name = "WeaponPivot"
	add_child(weapon_pivot)
	
	if start_weapon_scene:
		var weapon_instance = start_weapon_scene.instantiate()
		if weapon_instance is Weapon:
			equipped_weapon = weapon_instance
			equipped_weapon.position = Vector2(weapon_offset, 0)
			# The axe drawing faces -Y (up). To align it to face +X (right), rotate by PI/2.
			equipped_weapon.rotation = PI / 2.0
			weapon_pivot.add_child(equipped_weapon)


func _on_input_component_move_action(_velocity) -> void:
	velocity = _velocity
	move_and_slide()
	
	# Clamp position to screen bounds
	var viewport_rect := get_viewport_rect()
	if viewport_rect:
		position.x = clamp(position.x, radius, viewport_rect.size.x - radius)
		position.y = clamp(position.y, radius, viewport_rect.size.y - radius)
		
func _on_attack() -> void:
	if equipped_weapon and is_instance_valid(equipped_weapon):
		equipped_weapon.attack()
	
