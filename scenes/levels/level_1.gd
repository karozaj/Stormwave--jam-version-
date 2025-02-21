extends Node3D

@onready var player=$Player
@onready var preparation_phase_timer:Timer=$preparation_phase_timer
@onready var enemy_spawn_timer:Timer=$enemy_spawn_timer

var rng:RandomNumberGenerator=RandomNumberGenerator.new()

var spawners:Array
var enemy_spawn_chance:Dictionary
var current_wave:int=0
var max_selector:int=60
var is_battle_mode_active:bool=false
var block_reward:int=25

func _ready() -> void:
	Global.current_map=self
	enemy_spawn_chance={"rat":35, "projectile":61, "hitscan":72, "cloud":93,"rocket":100}
	spawners=[$enemy_spawner,$enemy_spawner2,$enemy_spawner3,$enemy_spawner4]
	begin_preparation_phase()

func _process(_delta: float) -> void:
	if player!=null:
		get_tree().call_group("enemy","update_target_location",player.global_transform.origin)
	if is_battle_mode_active==true:
		if get_tree().get_node_count_in_group("enemy")<=0:
			begin_preparation_phase()
	else:
		player.game_state_display.update_time_display(str(round(preparation_phase_timer.time_left)))

func spawn_wave():
	var new_wave:Array[String]=generate_wave()
	var subwaves:Array=divide_wave(new_wave)
	for i in range(0,spawners.size()):
		var subwave_to_spawn:Array[String]=subwaves[i]
		spawners[i].spawn_wave(subwave_to_spawn)

func generate_wave()->Array[String]:
	var wave:Array[String]
	wave=[]
	var wave_size:int
	if current_wave<=1:
		max_selector=60
		wave_size=4
		block_reward=25
	elif current_wave<=2:
		max_selector=60
		wave_size=6
		block_reward=25
	elif current_wave<=3:
		max_selector=72
		wave_size=8
		block_reward=25
	elif current_wave<=4:
		max_selector=72
		wave_size=10
		block_reward=25
	elif current_wave<=5:
		max_selector=72
		wave_size=12
		block_reward=25
	elif current_wave<=6:
		max_selector=90
		wave_size=14
		block_reward=25
	elif current_wave<=7:
		max_selector=97
		wave_size=16
		block_reward=25
	elif current_wave<=8:
		max_selector=100
		wave_size=18
		block_reward=40
	elif current_wave<=9:
		max_selector=100
		wave_size=20
		block_reward=50
	elif current_wave<=10:
		max_selector=100
		wave_size=22
		block_reward=55
	elif current_wave<=11:
		max_selector=100
		wave_size=24
		block_reward=55
	elif current_wave<=12:
		max_selector=100
		wave_size=30
		block_reward=60
	elif current_wave<=15:
		max_selector=100
		wave_size=35
		block_reward=60
	else:
		max_selector=100
		wave_size=40
		block_reward=60
		
	for i in range(0,wave_size):
		var selector=rng.randi_range(0,max_selector)
		print("selector", selector)
		if selector<=enemy_spawn_chance["rat"]:
			wave.append("rat")
		elif selector<=enemy_spawn_chance["projectile"]:
			wave.append("projectile")
		elif selector<=enemy_spawn_chance["hitscan"]:
			wave.append("hitscan")
		elif selector<=enemy_spawn_chance["cloud"]:
			wave.append("cloud")
		else:
			wave.append("rocket")
			
	return wave

func divide_wave(wave:Array[String])->Array:
	var subwave0:Array[String]=[]
	var subwave1:Array[String]=[]
	var subwave2:Array[String]=[]
	var subwave3:Array[String]=[]
	var subwaves:Array=[subwave0,subwave1,subwave2,subwave3]
	@warning_ignore("integer_division")
	var subwave_size:int=wave.size()/4
	for i in range(0,subwaves.size()):
		for j in range(0,subwave_size):
			subwaves[i].append(wave.pop_back())
	return subwaves

func begin_preparation_phase()->void:
	current_wave+=1
	if current_wave!=1:
		MusicPlayer.stop_battle_music()
	player.game_state_display.update_wave_info(str(current_wave))
	player.game_state_display.update_time_info_visibility(true)
	is_battle_mode_active=false
	player.weapon_manager.select_block_weapon()
	if current_wave>0:
		player.weapon_manager.add_blocks(block_reward)
	preparation_phase_timer.start()

func _on_preparation_phase_timer_timeout() -> void:
	player.weapon_manager.reset_weapon_selection()
	$AudioStreamPlayer.play()
	$NavigationRegion3D/block_gridmap.reset_block_highlight()
	MusicPlayer.play_battle_music()
	begin_battle_phase()

func begin_battle_phase()->void:
	print("wave ",current_wave)
	player.game_state_display.update_time_info_visibility(false)
	enemy_spawn_timer.start()
	spawn_wave()

func _on_enemy_spawn_timer_timeout() -> void:
	is_battle_mode_active=true

#check if player is allowed to build
func _on_building_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		body.weapon_manager.can_build=true

func _on_building_area_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		body.weapon_manager.can_build=false
