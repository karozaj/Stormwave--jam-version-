extends Node3D

@onready var animation_player:AnimationPlayer=$AnimationPlayer
@onready var audio_player:AudioStreamPlayer3D=$AudioStreamPlayer3D
@onready var damage_area=$Area3D
var default_pitch:float=1.0

@export var weapon_range:float=15.0
var rng=RandomNumberGenerator.new()
var cooldown:float=.5
var base_damage:int=50

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func allign_rays(ray_position:Vector3):
	damage_area.global_position=ray_position
	
func shoot():
	animation_player.play("swing")
	swing_attack()
	#if ray.is_colliding():
		#if ray.get_collider().has_method("damage"):
			#ray.get_collider().damage(base_damage)

func swing_attack():
	var targets:Array=damage_area.get_overlapping_bodies()
	for target in targets:
		if target.has_method("damage"):
			target.damage(base_damage, global_position)
	

func play_swinging_sound():
	audio_player.pitch_scale=default_pitch+rng.randf_range(-.1,.1)
	audio_player.play()

#func muzzle_flash_flip():
	#var flip_index:int=rng.randi_range(0,1)
	#if flip_index==0:
		#muzzle_flash.flip_h=!muzzle_flash.flip_h
	#else:
		#muzzle_flash.flip_v=!muzzle_flash.flip_v
