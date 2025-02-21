extends Node3D

@onready var spawn_marker:Marker3D=$spawn_position
@onready var spawn_area:Area3D=$spawn_position/spawn_area
var spawn_position:Vector3
var contains_body:bool=false

func _ready() -> void:
	spawn_position=spawn_marker.global_position

func _on_spawn_area_body_entered(_body: Node3D) -> void:
	spawn_position=spawn_marker.global_position
	contains_body=true
	#print(body.name)

func _on_spawn_area_body_exited(_body: Node3D) -> void:
	if spawn_area.get_overlapping_bodies().size()==0:
		#print(body.name)
		contains_body=false
		spawn_position=spawn_marker.global_position
