extends Node3D

@onready var spawn_timer:Timer=$spawn_timer

var rat_enemy_scene=preload("res://scenes/enemies/rat_enemy.tscn")
var hitscan_enemy_scene=preload("res://scenes/enemies/hitscan_enemy.tscn")
var projectile_enemy_scene=preload("res://scenes/enemies/projectile_enemy.tscn")
var cloud_enemy_scene=preload("res://scenes/enemies/cloud_enemy.tscn")
var rocket_enemy_scene=preload("res://scenes/enemies/rocket_enemy.tscn")

var rng:RandomNumberGenerator=RandomNumberGenerator.new()

var enemy_dict:Dictionary
var spawn_spots:Array
var wave_spawn_indexes:Array[int]
var current_wave:Array
var subwaves:Array
var current_subwave_index:int=0

func _ready() -> void:
	enemy_dict={"rat":rat_enemy_scene,"projectile":projectile_enemy_scene,"hitscan":hitscan_enemy_scene, "cloud":cloud_enemy_scene,"rocket":rocket_enemy_scene}
	spawn_spots=[$spawn_spot,$spawn_spot2,$spawn_spot3,$spawn_spot4,$spawn_spot5,$spawn_spot6,$spawn_spot7,$spawn_spot8,$spawn_spot9,$spawn_spot10,$spawn_spot11,$spawn_spot12,$spawn_spot13,$spawn_spot14,$spawn_spot15,$spawn_spot16,$spawn_spot17,$spawn_spot18]

func spawn_enemy(type_name:String,spawn_point_index:int)->void:
		var enemy=enemy_dict[type_name].instantiate()
		Global.current_map.add_child(enemy)
		if spawn_spots[spawn_point_index].contains_body==false:
			enemy.global_position=spawn_spots[spawn_point_index].global_position
		else:
			enemy.global_position=spawn_spots[spawn_point_index].global_position+Vector3(0,4.1,0)
		if type_name=="cloud":
			enemy.global_position+=Vector3(0,1,0)

func spawn_wave(wave:Array[String]):
	while wave.size()>18:
		wave.pop_back()
	
	wave_spawn_indexes=[]
	for i in range(0,wave.size()):
		wave_spawn_indexes.append(i)
	wave_spawn_indexes.shuffle()
	
	current_wave=[]
	for i in range(0,wave.size()):
		current_wave.append([wave[i],wave_spawn_indexes[i]])
	
	current_subwave_index=0
	subwaves=[[],[],[],[],[],[]]
	for i in range(0,subwaves.size()):
		for j in range(0,3):
			if current_wave.size()>0:
				subwaves[i].append(current_wave.pop_back())
	
	spawn_timer.start()


func _on_spawn_timer_timeout() -> void:
	for i in range(0,subwaves[current_subwave_index].size()):
		var current_enemy=subwaves[current_subwave_index][i][0]
		var current_enemy_spawn_point_index:int=subwaves[current_subwave_index][i][1]
		spawn_enemy(current_enemy, current_enemy_spawn_point_index)
	current_subwave_index+=1
	if current_subwave_index<6:
		spawn_timer.start()
