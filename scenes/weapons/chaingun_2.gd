extends Node3D

@onready var animation_player:AnimationPlayer=$shoot_animation_player
@onready var audio_player:AudioStreamPlayer3D=$AudioStreamPlayer3D
@onready var rays:Array[RayCast3D]=[$rays/ray_center, $rays/ray_top, $rays/ray_bottom, $rays/ray_right, $rays/ray_left]
@onready var muzzle_flash:Sprite3D=$Cylinder_001/tip/muzzle_flash
var default_pitch:float=1.0

#@export var weapon_range:float=15.0
var rng=RandomNumberGenerator.new()
var cooldown:float=.05
var base_damage:int=15

func allign_rays(ray_position:Vector3):
	$rays.global_position=ray_position

func shoot():
	animation_player.play("shoot")
	var ray_index:int=rng.randi_range(0,rays.size()-1)
	if rays[ray_index].is_colliding():
		if rays[ray_index].get_collider().has_method("damage"):
			rays[ray_index].get_collider().damage(base_damage, global_position)

func play_shooting_sound():
	audio_player.pitch_scale=default_pitch+rng.randf_range(-.075,.075)
	audio_player.play()

func muzzle_flash_flip():
	var flip_index:int=rng.randi_range(0,1)
	if flip_index==0:
		muzzle_flash.flip_h=!muzzle_flash.flip_h
	else:
		muzzle_flash.flip_v=!muzzle_flash.flip_v
