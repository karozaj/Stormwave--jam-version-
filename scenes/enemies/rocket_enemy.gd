extends CharacterBody3D

@onready var animation_player:AnimationPlayer=$AnimationPlayer
@onready var walk_sound_player:AudioStreamPlayer3D=$WalkSoundPlayer
@onready var sound_player:AudioStreamPlayer3D=$AudioStreamPlayer3D
@onready var cooldown_timer:Timer=$cooldown_timer
@onready var ray_left=$projectile_spawn_position_left/RayCast3D
@onready var ray_right=$projectile_spawn_position_right/RayCast3D

var pain_sound:AudioStream=load("res://assets/audio/enemies/grunt.ogg")
var death_sound:AudioStream=load("res://assets/audio/enemies/death_grunt.ogg")
var attack_sound:AudioStream=load("res://assets/audio/gun_sfx/rocket_launcher.ogg")

var projectile_scene=load("res://scenes/weapons/rocket_projectile.tscn")
var projectile

const SPEED = 3.0

var can_attack:bool=true
var is_dead:bool=false
@export var health:int=500
@export var knockback_modifier:float=15.0
@export var attack_cooldown:float=3.5
@export var attack_range:float=25.0

var rng:RandomNumberGenerator=RandomNumberGenerator.new()
var default_pitch:float=1.0
var gravity = 2.5*ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var player:CharacterBody3D=get_tree().get_first_node_in_group("player")

func _ready() -> void:
	add_to_group("enemy")
	cooldown_timer.wait_time=attack_cooldown

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

	if player==null or is_dead:
		return
	
	if Vector2(velocity.x, velocity.z).length()>0:
		if animation_player.is_playing()==false:
			animation_player.play("walk")
	
	var looking_direction=Vector3(player.global_position.x,global_position.y,player.global_position.z)	
	$projectile_spawn_position_left/RayCast3D.look_at(player.global_position+Vector3(0,1.5,0))
	$projectile_spawn_position_right/RayCast3D.look_at(player.global_position+Vector3(0,1.5,0))
	look_at(looking_direction)
	
	var current_location=global_transform.origin
	var next_location=player.global_position
	if current_location.distance_to(next_location)>attack_range:
		var new_velocity=(next_location-current_location).normalized()*SPEED
		velocity.x=velocity.move_toward(new_velocity,0.25).x
		velocity.z=velocity.move_toward(new_velocity,0.25).z
	else:
		var new_velocity=Vector3(0,0,0)
		velocity.x=velocity.move_toward(new_velocity,0.25).x
		velocity.z=velocity.move_toward(new_velocity,0.25).z
		if can_attack:
			can_attack=false
			cooldown_timer.start()
			var which_hand:int=rng.randi_range(0,1)
			if which_hand==0:
				animation_player.play("shoot_right")
			else:
				animation_player.play("shoot_left")
	
	move_and_slide()

func damage(damage_points:int, source_position:Vector3)->void:
	if is_dead==false:
		print(damage_points)
		if damage_points>=30:
			sound_player.stream=pain_sound
			sound_player.pitch_scale=default_pitch+rng.randf_range(-.15,.15)
			sound_player.play()
		health-=damage_points
		knockback(damage_points,source_position)
		if health<=0:
			die()
		
func knockback(damage_points:int,source:Vector3)->void:
	var knockback_direction:Vector3=global_position-source
	knockback_direction=knockback_direction.normalized()
	velocity+=knockback_direction*damage_points/100*knockback_modifier
	
func destroy_self()->void:
	queue_free()

func die():
	is_dead=true
	sound_player.stream=death_sound
	sound_player.play()
	animation_player.play("death")

func play_attack_sound():
	sound_player.stream=attack_sound
	sound_player.play()

func shoot_projectile_left():
	if Global.current_map!=null:
		projectile=projectile_scene.instantiate()
		#projectile.is_direction_reversed=true
		projectile.position=ray_left.global_position
		projectile.transform.basis=$projectile_spawn_position_left/RayCast3D.global_transform.basis
		#projectile.transform_basis=Basis(-ray_left.global_transform.basis.x,-ray_left.global_transform.basis.y,-ray_left.global_transform.basis.z)
		Global.current_map.add_child(projectile)
		
func shoot_projectile_right():
	if Global.current_map!=null:
		projectile=projectile_scene.instantiate()
		#projectile.is_direction_reversed=true
		projectile.position=$projectile_spawn_position_right.global_position
		projectile.transform.basis=$projectile_spawn_position_right/RayCast3D.global_transform.basis
		Global.current_map.add_child(projectile)
		
func _on_cooldown_timer_timeout() -> void:
	can_attack=true
