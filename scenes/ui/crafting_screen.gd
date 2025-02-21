extends Control

signal send_ammo_info(ammo_info:Dictionary, health_info:int)

@onready var health_button=$HBoxContainer/CraftingContainer/CraftingButtonsContainer/health_button
@onready var pistol_button=$HBoxContainer/CraftingContainer/CraftingButtonsContainer/pistol_button
@onready var shotgun_button=$HBoxContainer/CraftingContainer/CraftingButtonsContainer/shotgun_button
@onready var machine_gun_button=$HBoxContainer/CraftingContainer/CraftingButtonsContainer/machine_gun_button
@onready var rocket_launcher_button=$HBoxContainer/CraftingContainer/CraftingButtonsContainer/rocket_launcher_button
var buttons:Array[Button]

@export_group("Crafting cost")
@export var health_cost:int=1
@export var pistol_ammo_cost:int=2
@export var shotgun_ammo_cost:int=5
@export var machine_gun_ammo_cost:int=10
@export var rocket_launcher_ammo_cost:int=15

@export_group("Crafted resource count")
@export var health_count:int=25
@export var pistol_ammo_count:int=30
@export var shotgun_ammo_count:int=15
@export var machine_gun_ammo_count:int=75
@export var rocket_launcher_ammo_count:int=20
	
var costs:Array[int]
var purchasable_counts:Array[int]
var resource_labels:Array[Label]

var ammo_dictionary:Dictionary
var health_points:int

func _ready() -> void:
	Input.mouse_mode=Input.MOUSE_MODE_CONFINED
	buttons=[health_button, pistol_button, shotgun_button, machine_gun_button, rocket_launcher_button]
	costs=[health_cost, pistol_ammo_cost, shotgun_ammo_cost, machine_gun_ammo_cost, rocket_launcher_ammo_cost]
	purchasable_counts=[health_count, pistol_ammo_count, shotgun_ammo_count, machine_gun_ammo_count, rocket_launcher_ammo_count]
	resource_labels=[$HBoxContainer/ResourceInfoContainer/ResourcesContainer/AmmoInfoContainer/block, $HBoxContainer/ResourceInfoContainer/ResourcesContainer/AmmoInfoContainer/health, $HBoxContainer/ResourceInfoContainer/ResourcesContainer/AmmoInfoContainer/pistol, $HBoxContainer/ResourceInfoContainer/ResourcesContainer/AmmoInfoContainer/shotgun, $HBoxContainer/ResourceInfoContainer/ResourcesContainer/AmmoInfoContainer/machinegun, $HBoxContainer/ResourceInfoContainer/ResourcesContainer/AmmoInfoContainer/rocket]
	set_resource_cost_text()
	
	for btn in buttons:
		btn.pressed.connect(craft_resource.bind(btn.name))
	
	get_tree().paused=true
	show()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		Input.mouse_mode=Input.MOUSE_MODE_VISIBLE

func set_resource_cost_text()->void:
	for i in range(0,buttons.size()):
		buttons[i].text=buttons[i].text.replace("?", str(costs[i]))
		buttons[i].text=buttons[i].text.replace("!", str(purchasable_counts[i]))

func update_resource_counts(ammo_info:Dictionary, health:int)->void:
	ammo_dictionary=ammo_info
	health_points=health
	resource_labels[0].text=str(ammo_info["block_weapon"])
	resource_labels[1].text=str(health)
	resource_labels[2].text=str(ammo_info["pistol"])
	resource_labels[3].text=str(ammo_info["shotgun"])
	resource_labels[4].text=str(ammo_info["chaingun"])
	resource_labels[5].text=str(ammo_info["rocket_launcher"])
	update_button_availability()

func update_button_availability()->void:
	if health_points>=200 or ammo_dictionary["block_weapon"]<costs[0]:
		buttons[0].disabled=true
	else:
		buttons[0].disabled=false
		
	for i in range(1, buttons.size()):
		if ammo_dictionary["block_weapon"]<costs[i]:
			buttons[i].disabled=true
		else:
			buttons[i].disabled=false
		

func craft_resource(button_name:String):
	print(button_name)
	if button_name=="health_button":
		ammo_dictionary["block_weapon"]-=costs[0]
		if health_points<=200-purchasable_counts[0]:
			health_points+=purchasable_counts[0]
		else:
			health_points=200
		
	elif button_name=="pistol_button":
		ammo_dictionary["block_weapon"]-=costs[1]
		ammo_dictionary["pistol"]+=purchasable_counts[1]
		
	elif button_name=="shotgun_button":
		ammo_dictionary["block_weapon"]-=costs[2]
		ammo_dictionary["shotgun"]+=purchasable_counts[2]
		
	elif button_name=="machine_gun_button":
		ammo_dictionary["block_weapon"]-=costs[3]
		ammo_dictionary["chaingun"]+=purchasable_counts[3]
		
	elif button_name=="rocket_launcher_button":
		ammo_dictionary["block_weapon"]-=costs[4]
		ammo_dictionary["rocket_launcher"]+=purchasable_counts[4]
		
	update_button_availability()
	update_resource_counts(ammo_dictionary, health_points)

func _on_continue_button_pressed() -> void:
	Input.mouse_mode=Input.MOUSE_MODE_CAPTURED
	get_tree().paused=false
	send_ammo_info.emit(ammo_dictionary, health_points)
	queue_free()
