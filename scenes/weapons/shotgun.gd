extends Node3D

@onready var animation_player:AnimationPlayer=$AnimationPlayer
@onready var audio_player:AudioStreamPlayer3D=$AudioStreamPlayer3D
@onready var rays:Array[RayCast3D]=[$rays/ray_center, $rays/ray_top, $rays/ray_bottom, $rays/ray_right, $rays/ray_left]
@onready var muzzle_flash:Sprite3D=$Cylinder/tip/muzzle_flash
var default_pitch:float=1.0

#@export var weapon_range:float=15.0
var rng=RandomNumberGenerator.new()
var cooldown:float=.5
var base_damage:int=35

func allign_rays(ray_position:Vector3):
	$rays.global_position=ray_position

func shoot():
	animation_player.play("shoot")
	for ray in rays:
		if ray.is_colliding():
			if ray.get_collider().has_method("damage"):
				ray.get_collider().damage(base_damage+rng.randi_range(-5,5),global_position)

func play_shooting_sound():
	audio_player.pitch_scale=default_pitch+rng.randf_range(-.1,.1)
	audio_player.play()

func muzzle_flash_flip():
	var flip_index:int=rng.randi_range(0,1)
	if flip_index==0:
		muzzle_flash.flip_h=!muzzle_flash.flip_h
	else:
		muzzle_flash.flip_v=!muzzle_flash.flip_v
