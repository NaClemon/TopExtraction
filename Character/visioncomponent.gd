class_name VisionComponent
extends Node2D

# 시야 설정
@export var view_radius: float = 300.0   # 시야 거리
@export var view_angle: float = 90.0    # 시야각 (도 단위)
@export var resolution: int = 64

@export_group("View")
@export var vision_color: Color = Color(0.722, 0.722, 0.722, 1.0)

var _look_at: Vector2
var _vision_points: PackedVector2Array

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
func look(_towards: Vector2) -> void:
	if _look_at == _towards:
		return
		
	_look_at = _towards
	_calc_vision()
	queue_redraw()
	
func _draw():
	draw_vision()
	
func _calc_vision() -> void:
	_vision_points.clear()
	_vision_points.append(Vector2.ZERO)
	
	var half_view_angle = deg_to_rad(view_angle * 0.5)
	var look_angle = _look_at.angle()
	var space_state = get_world_2d().direct_space_state
	
	for i in range(resolution + 1):
		var angle = lerp(-half_view_angle, half_view_angle, float(i) / resolution)
		var dir = Vector2.from_angle(look_angle + angle).normalized()
		var end_point = (dir * view_radius)
		
		var query = PhysicsRayQueryParameters2D.create(Vector2.ZERO, end_point, 1)
		var ray_result = space_state.intersect_ray(query)
		
		if ray_result:
			_vision_points.append(ray_result["position"])
		else:
			_vision_points.append(end_point)

func update_vision(radius: float, angle: float):
	view_radius = radius
	view_angle = angle

func draw_vision() -> void:
	draw_polygon(_vision_points, [vision_color])
