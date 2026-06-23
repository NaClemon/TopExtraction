class_name Weapon
extends Area2D

signal attack_started
signal attack_finished

@export_group("Weapon Info")
@export var weapon_name: String = ""
@export var damage: float = 10.0
@export var attack_cooldown: float = 0.5

@export_group("Audio")
@export var attack_sound: AudioStream

@export_group("Flashlight")
@export var has_flashlight: bool = true
@export var light_length: float = 400.0
@export var light_width_degrees: float = 20.0
@export var light_offset: float = 35.0 # Distance from weapon center to start of light beam
@export var light_color: Color = Color(1.0, 0.95, 0.85, 1.0) # Warm white / realistic flashlight
@export var light_energy: float = 200.0
@export var enable_shadows: bool = true

var is_attacking: bool = false
var can_attack: bool = true

var sound_player: AudioStreamPlayer2D
var cone_light: PointLight2D

func _ready() -> void:
	# Automatically create and configure the audio player if a sound is assigned
	if attack_sound:
		sound_player = AudioStreamPlayer2D.new()
		sound_player.name = "AttackSoundPlayer"
		sound_player.stream = attack_sound
		add_child(sound_player)
	
	# Setup the Flashlight attached to the weapon
	setup_flashlight()

func setup_flashlight() -> void:
	if not has_flashlight:
		return
		
	var parent = get_parent()
	if not parent:
		return
		
	# Create PointLight2D node
	cone_light = PointLight2D.new()
	cone_light.name = "Flashlight"
	cone_light.color = light_color
	cone_light.energy = light_energy
	cone_light.shadow_enabled = enable_shadows
	
	# Generate procedural cone texture (256x256 resolution is ideal for smooth filtering and performance)
	var tex = generate_cone_texture(256, light_width_degrees)
	cone_light.texture = tex
	
	# Scale it so that the light spans exactly `light_length` pixels
	var scale_factor = light_length / 128.0
	cone_light.scale = Vector2(scale_factor, scale_factor)
	
	# Position the light relative to the WeaponPivot (which faces +X towards the mouse)
	# The weapon is at Vector2(weapon_offset, 0). We offset the light along +X by light_offset.
	cone_light.position = Vector2(position.x + light_offset, 0)
	cone_light.rotation = 0.0
	
	parent.add_child(cone_light)

func _exit_tree() -> void:
	if cone_light and is_instance_valid(cone_light):
		cone_light.queue_free()

func generate_cone_texture(resolution: int, angle_degrees: float) -> Texture2D:
	var img = Image.create(resolution, resolution, false, Image.FORMAT_RGBA8)
	var center = Vector2(resolution / 2.0, resolution / 2.0)
	var radius_px = resolution / 2.0
	var half_angle_rad = deg_to_rad(angle_degrees / 2.0)
	
	for y in range(resolution):
		for x in range(resolution):
			var pos = Vector2(x, y)
			var to_pixel = pos - center
			var dist = to_pixel.length()
			
			if dist <= radius_px and dist > 0.0:
				var angle = to_pixel.angle() # angle ranges from -PI to PI
				# Check if the angle is within our cone width (facing +X / Right direction)
				if abs(angle) <= half_angle_rad:
					var dist_factor = 1.0 - (dist / radius_px)
					var angle_factor = 1.0 - (abs(angle) / half_angle_rad)
					
					# Soft falloff styling
					dist_factor = clamp(dist_factor, 0.0, 1.0)
					angle_factor = clamp(angle_factor, 0.0, 1.0)
					
					var intensity = pow(dist_factor, 1.8) * pow(angle_factor, 1.6)
					img.set_pixel(x, y, Color(1.0, 1.0, 1.0, intensity))
				else:
					img.set_pixel(x, y, Color(0, 0, 0, 0))
			else:
				img.set_pixel(x, y, Color(0, 0, 0, 0))
				
	return ImageTexture.create_from_image(img)

func attack() -> void:
	if not can_attack or is_attacking:
		return
		
	# Play attack sound if valid
	if sound_player and is_instance_valid(sound_player):
		sound_player.play()
		
	_perform_attack()

# To be overridden by specific weapon scripts (like Axe)
func _perform_attack() -> void:
	pass
