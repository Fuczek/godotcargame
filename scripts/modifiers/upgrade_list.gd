extends Node

@onready var upgrade_menu = preload("res://scenes/next_upgrade_menu.tscn")
@onready var upgrade_button = preload("res://scenes/upgrade_button.tscn")
@export var available_upgrades_to_roll : Array[Resource]

var amount_of_upgrades_to_roll : int
var upgrades_to_show : Array[Resource]
var available_upgrades_default : Array[Resource] = available_upgrades_to_roll.duplicate(true)

signal instantiate_upgrade_button
signal add_modifiers

func pick_random_upgrade() -> Resource:
	return available_upgrades_to_roll[randi() % available_upgrades_to_roll.size()] as Resource

func _ready():
	instantiate_upgrade_button.connect(get_tree().get_first_node_in_group("hud_group").create_new_upgrade_button)
	available_upgrades_default = available_upgrades_to_roll.duplicate(true)
	#randomize_next_upgrade(false)

func randomize_next_upgrade(restart : bool):
	#This function happens every race.
	#We reset the available maps to roll to default array.
	available_upgrades_to_roll = available_upgrades_default.duplicate(true)
	var upgrade_random_modifiers : Array = []
	
	#We first choose the amount of maps to roll from the list and show to the player:
	if restart:
		amount_of_upgrades_to_roll = 2
	else:
		amount_of_upgrades_to_roll = randi_range(2, 3)
	
	var upgrade_menu_instance = upgrade_menu.instantiate()
	var hud_group = get_tree().get_first_node_in_group("hud_group")
	hud_group.add_child(upgrade_menu_instance)
	
	#next we choose individual maps from the list. For the first race, you only get one map:
	#for amount of maps to roll, if the available_maps array is not empty, we pick a random map. 
	#Then we erase that map from the avaialble_maps array, and add it to the array to show to the
	#player. The player can choose one of the maps that were chosen.
	for n in amount_of_upgrades_to_roll:
		if (available_upgrades_to_roll.size() > 0):
			var chosen_upgrade = pick_random_upgrade()
			available_upgrades_to_roll.erase(chosen_upgrade)
			upgrades_to_show.append(chosen_upgrade)
			#upgrade_random_modifiers.append(randomize_upgrade_modifiers())
	
	#for each map that has been randomly chosen, we emit a singal to the HUD to instantiate
	#a button that will spawn the specified map.
	var id = 0
	for upgrade in upgrades_to_show:
		emit_signal("instantiate_upgrade_button", upgrade)
		id += 1
		
	upgrades_to_show.clear()
