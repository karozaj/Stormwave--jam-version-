extends Area3D

@onready var timer:Timer=$projectile_lifetime_timer
@onready var audio_player:AudioStreamPlayer3D=$AudioStreamPlayer3D
@onready var hit_area:Area3D=$Area3D

var flying:bool=true
@export var projectile_speed:float=20.0
@export var direct_damage:float=40.0

func _ready() -> void:
	timer.start()

func _physics_process(delta: float) -> void:
	if flying:
		position-=transform.basis*Vector3(0,0,projectile_speed)*delta
			
func _on_body_entered(body: Node3D) -> void:
	$Sprite3D.visible=false
	if body.has_method("damage") and flying==true:
		body.damage(direct_damage, global_position)
	flying=false
	audio_player.play()

func _on_projectile_lifetime_timer_timeout() -> void:
	queue_free()

func _on_audio_stream_player_3d_finished() -> void:
	queue_free()
