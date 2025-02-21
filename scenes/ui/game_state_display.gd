extends Control

@onready var time_info:VBoxContainer=$VBoxContainer2
@onready var time_label:Label=$VBoxContainer2/TimeLabel
@onready var wave_number_label:Label=$VBoxContainer/WaveNumber

func update_time_display(time:String):
	time_label.text=time

func update_time_info_visibility(is_vis:bool):
	time_info.visible=is_vis

func update_wave_info(wave:String):
	wave_number_label.text=wave
