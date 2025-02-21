extends Node3D

@onready var audio_player:AudioStreamPlayer3D=$AudioStreamPlayer3D
@onready var place_block_sound:AudioStream=preload("res://assets/audio/place_block.ogg")
@onready var destroy_block_sound:AudioStream=preload("res://assets/audio/destroy_block.ogg")
@onready var animation_player=$AnimationPlayer
@onready var ray=$RayCast3D
var sound_place_block:AudioStream
var sound_destroy_block:AudioStream
var default_pitch:float=1.0

var rng=RandomNumberGenerator.new()
var cooldown:float=.25
	
func allign_rays(ray_position:Vector3):
	ray.global_position=ray_position

func destroy_block()->bool:
	if ray.is_colliding():
		if ray.get_collider().has_method("destroy_block"):
			if ray.get_collider().destroy_block(ray.get_collision_point()-ray.get_collision_normal()/2)==true:
				audio_player.stream=destroy_block_sound
				audio_player.play()
				animation_player.play("use")
				return true
	return false

func place_block()->bool:
	if ray.is_colliding():
		if ray.get_collider().has_method("place_block"):
			if check_block_clearance(ray.get_collision_point())==true:
				ray.get_collider().place_block(ray.get_collision_point()+ray.get_collision_normal()/2)
				audio_player.stream=place_block_sound
				audio_player.play()
				animation_player.play("use")
				return true
	return false

func check_block_clearance(target:Vector3)->bool:
	var distance=target.distance_to(ray.global_position-Vector3(0.0,0.775,0.0))
	if distance>1.5:
		return true
	return false

func highlight():
	if ray.is_colliding():
		if ray.get_collider().has_method("highlight"):
			ray.get_collider().highlight(ray.get_collision_point()-ray.get_collision_normal()/2)
