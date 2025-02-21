extends Control

@onready var ammo_label:Label=$VBoxContainer/AmmoContainer/AmmoLabel
@onready var health_label:Label=$VBoxContainer/HealthContainer/HealthLabel

func update_health_counter(health:int):
	health_label.text=str(health)
	if health<=25:
		health_label.modulate=Color(1, 0.084, 0.107)
	else:
		health_label.modulate=Color(1, 1, 1)
	
func update_ammo_counter(ammo_info:String):
	if ammo_info=="infinite":
		ammo_label.text="∞"
	else:
		ammo_label.text=ammo_info
