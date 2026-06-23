class_name Axe
extends Weapon

@export_group("Axe Settings")
@export var swing_arc: float = 120.0 # Swing arc in degrees
@export var swing_duration: float = 0.15 # Time to swing in seconds
@export var return_duration: float = 0.15 # Time to return to default stance

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	super() # Call parent Weapon._ready() to setup the audio player
	# Ensure the collision shape is disabled at start
	if collision_shape:
		collision_shape.disabled = true
	# Request drawing the vector graphics
	queue_redraw()

func _draw() -> void:
	# Draw Handle (Wood): Extends upwards (-Y direction)
	draw_line(Vector2(0, 15), Vector2(0, -45), Color(0.52, 0.37, 0.26), 6.0, true)
	
	# Draw Blade (Steel): Placed at the top end of the handle (-45px) facing right (+X)
	var blade_color = Color(0.7, 0.73, 0.78, 1.0)
	var edge_color = Color(0.9, 0.93, 0.98, 1.0)
	
	# Curve/shape of the axe head
	var points = PackedVector2Array([
		Vector2(0, -32),
		Vector2(25, -48),
		Vector2(28, -40),
		Vector2(20, -25),
		Vector2(0, -22)
	])
	draw_polygon(points, [blade_color])
	
	# Draw a glowing/sharp steel edge line
	draw_line(Vector2(25, -48), Vector2(28, -40), edge_color, 2.5, true)
	draw_line(Vector2(28, -40), Vector2(20, -25), edge_color, 2.5, true)

func _perform_attack() -> void:
	is_attacking = true
	can_attack = false
	
	if collision_shape:
		collision_shape.disabled = false
		
	# Swing calculation (rotate from negative half-arc to positive half-arc)
	var half_arc_rad = deg_to_rad(swing_arc / 2.0)
	rotation = -half_arc_rad
	
	var swing_tween = create_tween()
	
	# Perform the main fast swing
	swing_tween.tween_property(self, "rotation", half_arc_rad, swing_duration)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)
	
	# Finish attack swing, disable collision shape
	swing_tween.tween_callback(func():
		if collision_shape:
			collision_shape.disabled = true
		is_attacking = false
	)
	
	# Return to standard center stance smoothly
	swing_tween.tween_property(self, "rotation", 0.0, return_duration)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)
	
	# Cool down timer to re-enable attacking
	get_tree().create_timer(attack_cooldown).timeout.connect(func():
		can_attack = true
		attack_finished.emit()
	)
	
	attack_started.emit()
