extends Node
class_name MapList

@onready var map_menu = preload("res://scenes/next_map_menu.tscn")
@onready var map_button = preload("res://scenes/map_button.tscn")
@export var available_maps_to_roll : Array[Resource]
@export var available_reward_types_to_roll : Array[Resource]

var amount_of_maps_to_roll : int
var maps_to_show : Array[Resource]
var available_maps_default : Array[Resource] = available_maps_to_roll.duplicate(true)

signal instantiate_button
signal add_modifiers

func pick_random_map() -> Resource:
	return available_maps_to_roll[randi() % available_maps_to_roll.size()] as Resource

func _ready():
	instantiate_button.connect(get_tree().get_first_node_in_group("hud_group").create_new_button)
	available_maps_default = available_maps_to_roll.duplicate(true)
	randomize_next_map(false)

func randomize_next_map(restart : bool):
	#This function happens every race.
	#We reset the available maps to roll to default array.
	available_maps_to_roll = available_maps_default.duplicate(true)
	var map_random_modifiers : Array = []
	var rewards_to_show : Array = []
	
	#We first choose the amount of maps to roll from the list and show to the player:
	if restart:
		amount_of_maps_to_roll = 1
	else:
		amount_of_maps_to_roll = randi_range(2, 3)
	
	#print(amount_of_maps_to_roll)
	var map_menu_instance = map_menu.instantiate()
	var hud_group = get_tree().get_first_node_in_group("hud_group")
	hud_group.add_child(map_menu_instance)
	
	#next we choose individual maps from the list. For the first race, you only get one map:
	#for amount of maps to roll, if the available_maps array is not empty, we pick a random map. 
	#Then we erase that map from the avaialble_maps array, and add it to the array to show to the
	#player. The player can choose one of the maps that were chosen.

	var rewards_scripts : Array[Resource]
	for n in amount_of_maps_to_roll:
		if (available_maps_to_roll.size() > 0):
			var chosen_map = pick_random_map()
			available_maps_to_roll.erase(chosen_map)
			maps_to_show.append(chosen_map)
			var reward_script = randomize_map_rewards()
			rewards_scripts.append(reward_script)
			rewards_to_show.append(reward_script.icon)
			map_random_modifiers.append(randomize_map_modifiers())
	
	#for each map that has been randomly chosen, we emit a singal to the HUD to instantiate
	#a button that will spawn the specified map.
	var id = 0
	for map in maps_to_show:
		emit_signal("instantiate_button", map, map_random_modifiers[id], rewards_scripts[id], rewards_to_show[id])
		id += 1
	
	maps_to_show.clear()

func randomize_map_modifiers():
	var modifiers : Array[Resource]
	
	#create lap amount modifier:
	var random_lap_number : int = randi_range(1, 3)
	var lap_modifier : Resource
	match(random_lap_number):
		1:
			lap_modifier = load("res://scripts/modifiers/laps_1_mod.gd")
		2:
			lap_modifier = load("res://scripts/modifiers/laps_2_mod.gd")
		3:
			lap_modifier = load("res://scripts/modifiers/laps_3_mod.gd")
	modifiers.append(lap_modifier)
	
	var random_enemy_amount : int = randi_range(1, 3)
	var enemy_amount : Resource
	match(random_enemy_amount):
		1:
			enemy_amount = load("res://scripts/modifiers/enemies_1_modifier.gd")
		2:
			enemy_amount = load("res://scripts/modifiers/enemies_2_modifier.gd")
		3:
			enemy_amount = load("res://scripts/modifiers/enemies_3_modifier.gd")
	
	modifiers.append(enemy_amount)
	return modifiers

func randomize_map_rewards():
	var random_reward = available_reward_types_to_roll.pick_random()
	var random_reward_resource = random_reward.new()
	return random_reward_resource
	
