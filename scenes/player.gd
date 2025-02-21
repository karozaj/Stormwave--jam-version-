extends CharacterBody3D

const SENSITIVITY=0.004
const SPEED = 5.0
const SPRINT_SPEED=10.0
const JUMP_VELOCITY = 6.5

@onready var camera:Camera3D=$Pivot/Camera3D
@onready var gun_camera:Camera3D=$Pivot/GunCamera3D
@onready var pivot:Node3D=$Pivot
@onready var raycast:RayCast3D=$Pivot/Camera3D/RayCast3D
@onready var weapon_manager=$Pivot/GunCamera3D/WeaponManager
@onready var footstep_audio_player:AudioStreamPlayer3D=$footstep_audio_player
@onready var landing_sound_player:AudioStreamPlayer3D=$landing_sound_player
@onready var coyote_timer:Timer=$coyote_time_timer
@onready var jump_buffer_timer:Timer=$jump_buffer_timer
@onready var ammo_display=$CanvasLayer/AmmoDisplay
@onready var hurt_animation_player=$hurt_animation
@onready var game_state_display=$CanvasLayer/GameStateDisplay

var speed:float=SPEED
var movement_lerp_val:float=0.15
var was_on_floor:bool=true
var jump_available:bool=true
var jump_buffer:bool=false
var is_jumping:bool=false
var gravity:float
var knockback_modifier:float=20.0

var health:int=100
var is_dead:bool=false

func _ready():
	Global.player=self
	add_to_group("player")
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	RenderingServer.viewport_attach_camera($CanvasLayer/SubViewportContainer/SubViewport.get_viewport_rid(),gun_camera.get_camera_rid())
	gravity=ProjectSettings.get_setting("physics/3d/default_gravity")
	weapon_manager.send_ammo_info.connect(update_ammo_counter)
	update_ammo_counter(weapon_manager.get_current_ammo())

func _unhandled_input(event):
	if is_dead:
		return
	
	if event.is_action("open_ammo_shop") and weapon_manager.is_block_mode_active==true:
		create_crafting_menu()
		
	if event.is_action("exit"):
		create_pause_menu()
		
	if event is InputEventMouseMotion:
		pivot.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		gun_camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))
		gun_camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))
		
func _process(_delta: float) -> void:
	if is_dead:
		return
		
	if is_on_floor() and abs(Vector2(velocity.x,velocity.z).length())>=2.0:
		if footstep_audio_player.playing==false:
			footstep_audio_player.pitch_scale=1.0+(abs(Vector2(velocity.x,velocity.z).length())-SPEED)/SPRINT_SPEED
			footstep_audio_player.play()
	if is_on_floor()==true and was_on_floor==false:
		landing_sound_player.play()
	was_on_floor=is_on_floor()
		


func _physics_process(delta):
	if is_dead:
		return
		
	if Input.is_action_pressed("sprint"):
		speed=SPRINT_SPEED
	else:
		speed=SPEED

	if not is_on_floor():
		if jump_available:
			if coyote_timer.is_stopped():
				coyote_timer.start()
		if velocity.y>=0 and Input.is_action_pressed("jump"):
			velocity.y -= gravity * delta
		elif velocity.y>0:
			velocity.y -= 2.0*gravity * delta
		else:
			velocity.y-= 1.5*gravity * delta
	else:
		jump_available=true
		coyote_timer.stop()
		if jump_buffer:
			jump()
			
	if Input.is_action_just_pressed("jump"):
		if jump_available:
			jump()
		else:
			jump_buffer=true
			jump_buffer_timer.start()

	
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	direction=direction.rotated(Vector3.UP, pivot.rotation.y)

	if direction:
		velocity.x = lerp(velocity.x,direction.x * speed,movement_lerp_val)
		velocity.z = lerp(velocity.z,direction.z * speed,movement_lerp_val)
	else :
		velocity.x = lerp(velocity.x,0.0,movement_lerp_val)
		velocity.z = lerp(velocity.z,0.0,movement_lerp_val)

	move_and_slide()

func jump():
	velocity.y=JUMP_VELOCITY
	jump_available=false
	
func _on_jump_buffer_timer_timeout() -> void:
	jump_buffer=false

func _on_coyote_time_timer_timeout() -> void:
	jump_available=false

func update_ammo_counter(ammo_info:String)->void:
	ammo_display.update_ammo_counter(ammo_info)
	
func heal(heal_points:int)->void:
	if health+heal_points>200:
		health=200
	else:
		health+=heal_points
	ammo_display.update_health_counter(health)
	
	
func damage(damage_points:int, source_position:Vector3)->void:
	if is_dead==false:
		health-=damage_points
		knockback(damage_points,source_position)
		hurt_animation_player.play("hurt")
		ammo_display.update_health_counter(health)
		if health<=0:
			die()

func knockback(damage_points:int,source:Vector3)->void:
	var knockback_direction:Vector3=global_position-source
	knockback_direction=knockback_direction.normalized()
	velocity+=knockback_direction*damage_points/100*knockback_modifier
	
func die()->void:
	if is_dead==false:
		MusicPlayer.stop_battle_music()
		weapon_manager.is_parent_dead=true
		is_dead=true
		hurt_animation_player.play("death")

func create_pause_menu()->void:
	var pause_menu=preload("res://scenes/ui/pause_menu.tscn").instantiate()
	$CanvasLayer.add_child(pause_menu)

func create_crafting_menu()->void:
		var crafting_menu=preload("res://scenes/ui/crafting_screen.tscn").instantiate()
		$CanvasLayer.add_child(crafting_menu)
		crafting_menu.send_ammo_info.connect(update_resource_info)
		crafting_menu.update_resource_counts(weapon_manager.ammo,health)

func create_death_menu()->void:
		var death_menu=preload("res://scenes/ui/death_menu.tscn").instantiate()
		$CanvasLayer.add_child(death_menu)

func update_resource_info(ammo_info:Dictionary, health_info:int)->void:
	weapon_manager.ammo=ammo_info
	health=health_info
	update_ammo_counter(str(weapon_manager.ammo[weapon_manager.current_weapon.name]))
	ammo_display.update_health_counter(health)
