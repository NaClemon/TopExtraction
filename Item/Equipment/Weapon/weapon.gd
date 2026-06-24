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

var is_attacking: bool = false
var can_attack: bool = true

var sound_player: AudioStreamPlayer2D

func _ready() -> void:
	# Automatically create and configure the audio player if a sound is assigned
	if attack_sound:
		sound_player = AudioStreamPlayer2D.new()
		sound_player.name = "AttackSoundPlayer"
		sound_player.stream = attack_sound
		add_child(sound_player)

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
