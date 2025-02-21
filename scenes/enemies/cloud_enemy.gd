extends CharacterBody3D

@onready var cooldown_timer:Timer=$cooldown_timer
@onready var cloud_sprite:Sprite3D=$cloud_sprite
@onready var lightning_sprite:Sprite3D=$lightning_sprite
@onready var ray:RayCast3D=$RayCast3D
@onready var audio_player:AudioStreamPlayer3D=$AudioStreamPlayer3D
@onready var pain_sound_player:AudioStreamPlayer3D=$pain_audio_player
@onready var animation_player:AnimationPlayer=$AnimationPlayer

var charge_sound:AudioStream=load("res://assets/audio/enemies/charge.ogg")
var thunder_sound:AudioStream=load("res://assets/audio/enemies/thunder.ogg")
var pain_sound:AudioStream=load("res://assets/audio/enemies/grunt.ogg")
var death_sound:AudioStream=load("res://assets/audio/enemies/death_grunt.ogg")

var lightning_sprite_height:float
var rng:RandomNumberGenerator=RandomNumberGenerator.new()

const SPEED = 12.0

var can_attack:bool=true
var is_dead:bool=false
@export var health:int=100
@export var base_damage:int=95
@export var attack_cooldown:float=1.0
@export var attack_range:float=0.5
@export var height_over_target:float=7.5
@export var default_pitch=1.5

@onready var player:CharacterBody3D=get_tree().get_first_node_in_group("player")

func _ready() -> void:
	add_to_group("enemy")
	cooldown_timer.wait_time=attack_cooldown
	lightning_sprite_height=64*lightning_sprite.pixel_size
	print(lightning_sprite_height)

func _physics_process(_delta: float) -> void:
	if player==null or is_dead:
		return
	
	cloud_sprite.look_at(player.global_position)
	lightning_sprite.look_at(Vector3(player.global_position.x,lightning_sprite.global_position.y,player.global_position.z))
	
	if player.weapon_manager.has_no_ammo()==true:
		height_over_target=4.5
	else:
		height_over_target=7.5
	
	var current_location=global_transform.origin
	var next_location=player.global_position+Vector3(0,height_over_target,0)
	if Vector2(current_location.x,current_location.z).distance_to(Vector2(next_location.x,next_location.z))>attack_range and animation_player.is_playing()==false:
		var new_velocity=(next_location-current_location).normalized()*SPEED
		velocity.x=velocity.move_toward(new_velocity,0.125).x
		velocity.y=velocity.move_toward(new_velocity,0.125).y
		velocity.z=velocity.move_toward(new_velocity,0.125).z
	else:
		velocity.x=velocity.move_toward(Vector3(0,0,0),0.5).x
		velocity.y=velocity.move_toward(Vector3(0,0,0),0.5).y
		velocity.z=velocity.move_toward(Vector3(0,0,0),0.5).z
		if can_attack:
			animation_player.play("attack")
			can_attack=false
			cooldown_timer.start()
	
	move_and_slide()


func damage(damage_points:int, _source_position:Vector3)->void:
	if is_dead==false:
		print(damage_points)
		pain_sound_player.stream=pain_sound
		pain_sound_player.pitch_scale=default_pitch+rng.randf_range(-.15,.15)
		pain_sound_player.play()
		health-=damage_points
		if health<=0:
			die()
	
func destroy_self()->void:
	queue_free()

func die():
	is_dead=true
	pain_sound_player.pitch_scale=default_pitch
	pain_sound_player.stream=death_sound
	pain_sound_player.play()
	animation_player.play("death")

func attack()->void:
	if ray.is_colliding():
		calculate_lightning_size(ray.get_collider().global_position)
		if ray.get_collider().has_method("destroy_block"):
			ray.get_collider().destroy_block(ray.get_collision_point()-ray.get_collision_normal()/2)
		elif ray.get_collider().has_method("damage"):
			ray.get_collider().damage(base_damage,global_position)

func play_charge_sound()->void:
	audio_player.pitch_scale=0.5
	audio_player.stream=charge_sound
	audio_player.play()

func play_thunder_sound()->void:
	audio_player.pitch_scale=1.0
	audio_player.stream=thunder_sound
	audio_player.play()

func calculate_lightning_size(target_position:Vector3):
	var distance:float=global_position.distance_to(target_position)
	var lightning_position:float=distance/2
	lightning_sprite.position=Vector3(0,-lightning_position,0)
	lightning_sprite.scale.y=distance/lightning_sprite_height

func _on_cooldown_timer_timeout() -> void:
	can_attack=true
