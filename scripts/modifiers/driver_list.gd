extends Node

@export var level_1_drivers : Array[Resource]
@export var level_1_bosses : Array[Resource]
var drivers_to_add : Array[Resource]
var available_drivers_default : Array[Resource]
var player_data_modifiers

signal instantiate_upgrade_button
signal add_modifiers

func _ready():
	available_drivers_default = level_1_drivers.duplicate(true)
	#randomize_next_upgrade(false)

func randomize_drivers(player_level, driver_amount):
	level_1_drivers = available_drivers_default.duplicate(true)
	
	for n in driver_amount:
		if (level_1_drivers.size() > 0):
			var picked_driver = level_1_drivers.pick_random()
			level_1_drivers.erase(picked_driver)
			drivers_to_add.append(picked_driver)
