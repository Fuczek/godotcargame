extends Node
class_name MapList

@onready var map_menu = preload("res://scenes/next_map_menu.tscn")
@onready var map_button = preload("res://scenes/map_button.tscn")
@export var maps : Array[Resource]
var maps_to_roll : int = randi_range(2, 3) 
var maps_to_show : Array[Resource]

signal instantiate_button

func pick_random_map() -> Resource:
	return maps[randi() % maps.size()] as Resource

func _ready():
	instantiate_button.connect(get_tree().get_first_node_in_group("hud_group").create_new_button)
	randomize_next_map()	

func randomize_next_map():
	var map_menu_instance = map_menu.instantiate()
	var hud_group = get_tree().get_first_node_in_group("hud_group")
	hud_group.add_child(map_menu_instance)
	
	for n in maps_to_roll:
		if (maps.size() > 0):
			var chosen_map = pick_random_map()
			maps.erase(chosen_map)
			maps_to_show.append(chosen_map)
			
	for map in maps_to_show:
		emit_signal("instantiate_button", map)
