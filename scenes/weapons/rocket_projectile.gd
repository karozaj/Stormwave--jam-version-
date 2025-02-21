extends Area3D


@onready var timer:Timer=$projectile_lifetime_timer
@onready var audio_player:AudioStreamPlayer3D=$AudioStreamPlayer3D
@onready var explosion_area:Area3D=$Area3D

var flying:bool=true
var is_exploding:bool=false
@export var projectile_speed:float=15.0
var explosion_radius:float
@export var max_explosion_damage:float=200.0
@export var direct_damage:float=150.0

var rays:Array[RayCast3D]

func _ready() -> void:
	rays=[$RayCast3D,$RayCast3D2,$RayCast3D3,$RayCast3D4,$RayCast3D5,$RayCast3D6,$RayCast3D7,$RayCast3D8,$RayCast3D9]
	timer.start()
	explosion_radius=$Area3D/CollisionShape3D.shape.radius

func _physics_process(delta: float) -> void:
	if flying:
		position-=transform.basis*Vector3(0,0,projectile_speed)*delta
			
func _on_body_entered(body: Node3D) -> void:
	set_deferred("monitoring",false)
	$Sprite3D.visible=false
	flying=false
	if body.has_method("damage"):
		body.damage(direct_damage,global_position)
	for ray in rays:
		if ray.is_colliding():
			if ray.get_collider().has_method("destroy_block"):
				ray.get_collider().destroy_block(ray.get_collision_point()-ray.get_collision_normal()/2)
		#elif ray.get_collider().has_method("damage"):
			#ray.get_collider().damage(direct_damage,global_position)
	explode()
	$AnimationPlayer.play("explode")

func explode()->void:
	$ExplosionSprite.visible=true
	var targets:Array=explosion_area.get_overlapping_bodies()
	for target in targets:
		if target.has_method("damage"):
			var distance:float=global_position.distance_to(target.global_position)
			var damage_modifier:float=abs(explosion_radius-distance)/explosion_radius
			var calculated_damage:int=int(max_explosion_damage*damage_modifier)
			target.damage(calculated_damage, global_position)

func _on_projectile_lifetime_timer_timeout() -> void:
	queue_free()
