extends CharacterBody3D

@onready var nav_agent:NavigationAgent3D=$NavigationAgent3D
@onready var animation_player:AnimationPlayer=$AnimationPlayer
@onready var audio_player:AudioStreamPlayer3D=$AudioStreamPlayer3D
@onready var skitter_audio_player:AudioStreamPlayer3D=$SkitterAudioPlayer
@onready var ray:RayCast3D=$RayCast3D
@onready var cooldown_timer:Timer=$Timer
var pain_sound:AudioStream=load("res://assets/audio/enemies/rat_pain.ogg")
var death_sound:AudioStream=load("res://assets/audio/enemies/rat_death.ogg")
var attack_sound:AudioStream=load("res://assets/audio/enemies/rat_attack.ogg")
var rng:RandomNumberGenerator=RandomNumberGenerator.new()
var default_pitch:float=1.5

const SPEED = 8.0
const JUMP_VELOCITY = 4.5


var can_attack:bool=true
var is_dead:bool=false
@export var health:int=35
@export var base_damage:int=5
@export var knockback_modifier:float=50.0
@export var attack_cooldown:float=1.0

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var player:CharacterBody3D=get_tree().get_first_node_in_group("player")

func _ready() -> void:
	add_to_group("enemy")
	cooldown_timer.wait_time=attack_cooldown
	
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if player==null or is_dead:
		return
		
	var current_location=global_transform.origin
	var next_location=nav_agent.get_next_path_position()
	var new_velocity=(next_location-current_location).normalized()*SPEED
	velocity.x=velocity.move_toward(new_velocity,0.25).x
	velocity.z=velocity.move_toward(new_velocity,0.25).z
	var looking_direction=Vector3(player.global_position.x,global_position.y,player.global_position.z)
	look_at(looking_direction)
	
	if can_attack==false and animation_player.is_playing()==false:
		animation_player.play("idle")
	
	#var dir=player.global_position-global_position
	#dir.y=0.0
	#dir=dir.normalized()
	#velocity.x=dir.x*SPEED
	#velocity.z=dir.z*SPEED

	if ray.is_colliding():
		if ray.get_collider().is_in_group("player") and can_attack:
			attack(ray.get_collider())
		elif is_on_floor():
			jump()
	
	move_and_slide()


func update_target_location(target_location)->void:
	nav_agent.target_position=target_location

func jump()->void:
	velocity.y+=5.0
	
func damage(damage_points:int, source_position:Vector3)->void:
	if is_dead==false:
		print(damage_points)
		audio_player.stream=pain_sound
		audio_player.pitch_scale=default_pitch+rng.randf_range(-.25,.05)
		audio_player.play()
		health-=damage_points
		knockback(damage_points,source_position)
		if health<=0:
			die()

func die()->void:
	is_dead=true
	skitter_audio_player.stop()
	audio_player.stream=death_sound
	audio_player.play()
	animation_player.play("death")

func destroy_self()->void:
	queue_free()

func knockback(damage_points:int,source:Vector3)->void:
	var knockback_direction:Vector3=global_position-source
	knockback_direction=knockback_direction.normalized()
	velocity+=knockback_direction*damage_points/100*knockback_modifier

func attack(target)->void:
	can_attack=false
	cooldown_timer.start()
	audio_player.stream=attack_sound
	audio_player.play()
	animation_player.play("bite")
	target.damage(base_damage,global_position)

func _on_timer_timeout() -> void:
	can_attack=true
