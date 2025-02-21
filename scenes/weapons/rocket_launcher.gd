extends Node3D

@onready var animation_player:AnimationPlayer=$AnimationPlayer
@onready var audio_player:AudioStreamPlayer3D=$AudioStreamPlayer3D
var default_pitch:float=1.0

var projectile_scene=load("res://scenes/weapons/rocket_projectile.tscn")
var projectile

var rng=RandomNumberGenerator.new()
var cooldown:float=1.0

func shoot():
	animation_player.play("shoot")
	projectile=projectile_scene.instantiate()
	#this is so that the rocket doesnt collide with the player when they shoot downward
	projectile.set_collision_mask_value(1,false)
	projectile.position=$Cube_001/tip.global_position
	projectile.transform.basis=$RayCast3D.global_transform.basis
	if Global.current_map!=null:
		Global.current_map.add_child(projectile)

func play_shooting_sound():
	audio_player.pitch_scale=default_pitch+rng.randf_range(-.1,.05)
	audio_player.play()
