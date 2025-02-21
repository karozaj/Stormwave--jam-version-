extends Node

var current_map
var player

func get_volume(bus_name:String)->float:
	var bus_index= AudioServer.get_bus_index(bus_name)
	var volume_db:float=AudioServer.get_bus_volume_db(bus_index)
	return db_to_linear(volume_db)

func update_bus_volume(bus_name:String,value:float)->void:
	var bus_index= AudioServer.get_bus_index(bus_name)
	AudioServer.set_bus_volume_db(bus_index,linear_to_db(value))

func is_fullscreen()->bool:
	if DisplayServer.window_get_mode()==DisplayServer.WINDOW_MODE_FULLSCREEN:
		return true
	else:
		return false
