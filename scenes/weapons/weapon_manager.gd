extends Node3D

signal send_ammo_info(info:String)

var rng=RandomNumberGenerator.new()

@onready var cooldown_timer:Timer=$weapon_cooldown_timer
@onready var animation_player:AnimationPlayer=$AnimationPlayer
@onready var audio_player:AudioStreamPlayer3D=$AudioStreamPlayer3D
@onready var ray_position:Marker3D=$ray_position

var sound_no_ammo:AudioStream=preload("res://assets/audio/gun_sfx/no_ammo.ogg")
var sound_weapon_select:AudioStream=preload("res://assets/audio/gun_sfx/change_weapon.ogg")

var block
var axe
var pistol
var shotgun
var chaingun
var rocket_launcher
var weapons:Array
var weapon_select_animations:Array=["axe_select","pistol_select", "shotgun_select", "chaingun_select", "rocket_launcher_select"]
var is_block_mode_active:bool=false
var can_build:bool=false
var can_shoot:bool=true
var ammo:Dictionary={"block_weapon":0, "axe":"infinite", "pistol":150, "shotgun":30, "chaingun":350,"rocket_launcher":10}
var current_weapon
var current_weapon_index:int
var is_pulling_out_weapon:bool=false
var is_parent_dead:bool=false

func _ready() -> void:
	is_pulling_out_weapon=false
	can_shoot=true
	block=$right_position/block_weapon
	axe=$right_position/axe
	pistol=$right_position/pistol
	shotgun=$right_position/shotgun
	chaingun=$center_position/chaingun
	rocket_launcher=$center_position/rocket_launcher
	weapons=[axe,pistol,shotgun,chaingun,rocket_launcher]
	for weapon in weapons:
		if weapon.has_method("allign_rays"):
			weapon.allign_rays(ray_position.global_position)
	block.allign_rays(ray_position.global_position)
	
	reset_weapon_selection()
	
func _process(_delta: float) -> void:
	#TODO: DELETE TEST ACTION
	#if Input.is_action_just_pressed("TEST"):
		#if is_block_mode_active:
			#reset_weapon_selection()
		#else:
			#select_block_weapon()
			
	if is_parent_dead==false and is_pulling_out_weapon==false:
		if is_block_mode_active==false:
			handle_shooting()
			select_weapon()
		else:
			handle_block_interaction()

func select_weapon()->void:
	if Input.is_action_just_pressed("select_weapon_1"):
		current_weapon.visible=false
		current_weapon=axe
		current_weapon_index=0
		animation_player.play("axe_select")
		send_ammo_info.emit(str(ammo[current_weapon.name]))
		play_weapon_select_sound()
	elif Input.is_action_just_pressed("select_weapon_2"):
		current_weapon.visible=false
		current_weapon=pistol
		current_weapon_index=1
		animation_player.play("pistol_select")
		send_ammo_info.emit(str(ammo[current_weapon.name]))
		play_weapon_select_sound()
	elif Input.is_action_just_pressed("select_weapon_3"):
		current_weapon.visible=false
		current_weapon=shotgun
		current_weapon_index=2
		animation_player.play("shotgun_select")
		send_ammo_info.emit(str(ammo[current_weapon.name]))
		play_weapon_select_sound()
	elif Input.is_action_just_pressed("select_weapon_4"):
		current_weapon.visible=false
		current_weapon=chaingun
		current_weapon_index=3
		animation_player.play("chaingun_select")
		send_ammo_info.emit(str(ammo[current_weapon.name]))
		play_weapon_select_sound()
	elif Input.is_action_just_pressed("select_weapon_5"):
		current_weapon.visible=false
		current_weapon=rocket_launcher
		current_weapon_index=4
		animation_player.play("rocket_launcher_select")
		send_ammo_info.emit(str(ammo[current_weapon.name]))
		play_weapon_select_sound()
		
	elif Input.is_action_just_pressed("next_weapon"):
		current_weapon.visible=false
		current_weapon_index=(current_weapon_index+1)%weapons.size()
		current_weapon=weapons[current_weapon_index]
		animation_player.play(weapon_select_animations[current_weapon_index])
		send_ammo_info.emit(str(ammo[current_weapon.name]))
		play_weapon_select_sound()
	elif Input.is_action_just_pressed("previous_weapon"):
		current_weapon.visible=false
		current_weapon_index=(current_weapon_index-1)%weapons.size()
		current_weapon=weapons[current_weapon_index]
		animation_player.play(weapon_select_animations[current_weapon_index])
		send_ammo_info.emit(str(ammo[current_weapon.name]))
		play_weapon_select_sound()

func play_weapon_select_sound():
	audio_player.stream=sound_weapon_select
	audio_player.play()

func shoot_weapon()->void:
	current_weapon.shoot()
	if ammo[current_weapon.name] is int:
		ammo[current_weapon.name]-=1
		send_ammo_info.emit(str(ammo[current_weapon.name]))
	can_shoot=false
	cooldown_timer.start(current_weapon.cooldown)

func has_ammo(weapon_name:String)->bool:
	if ammo[weapon_name] is not int or ammo[weapon_name]>0:
		return true
	return false

func _on_weapon_cooldown_timer_timeout() -> void:
	can_shoot=true

func handle_shooting()->void:
	if is_pulling_out_weapon==false:
		if current_weapon==chaingun:
			if Input.is_action_pressed("shoot") and can_shoot:
				if has_ammo(current_weapon.name):
					shoot_weapon()
				else:
					audio_player.stream=sound_no_ammo
					audio_player.play()
		else:
			if Input.is_action_just_pressed("shoot") and can_shoot:
				if has_ammo(current_weapon.name):
					shoot_weapon()
				else:
					audio_player.stream=sound_no_ammo
					audio_player.play()
	
func select_block_weapon()->void:
	current_weapon.visible=false
	current_weapon=block
	current_weapon.visible=true
	current_weapon_index=-1
	is_block_mode_active=true
	send_ammo_info.emit(str(ammo[current_weapon.name]))

func reset_weapon_selection()->void:
	block.visible=false
	is_block_mode_active=false
	can_shoot=true
	is_pulling_out_weapon=false
	current_weapon=axe
	current_weapon_index=0
	current_weapon.visible=true
	send_ammo_info.emit(str(ammo[current_weapon.name]))

func handle_block_interaction()->void:
	current_weapon.highlight()
	if Input.is_action_just_pressed("shoot"):
		if current_weapon.destroy_block()==true:
			ammo["block_weapon"]+=1
			send_ammo_info.emit(str(ammo[current_weapon.name]))
	if Input.is_action_just_pressed("place_block") and can_build:
		if ammo["block_weapon"]>0:
			if current_weapon.place_block()==true:
				ammo["block_weapon"]-=1
				send_ammo_info.emit(str(ammo[current_weapon.name]))
		else:
			audio_player.stream=sound_no_ammo
			audio_player.play()

func get_current_ammo()->String:
	return str(ammo[current_weapon.name])

func add_blocks(how_many:int):
	ammo["block_weapon"]+=how_many
	send_ammo_info.emit(str(ammo["block_weapon"]))

func has_no_ammo()->bool:
	if ammo["pistol"]==0 and ammo["shotgun"]==0 and ammo["chaingun"]==0 and ammo["rocket_launcher"]==0:
		return true
	return false
