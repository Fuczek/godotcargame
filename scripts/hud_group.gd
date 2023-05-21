extends Control

@onready var map_button = preload("res://scenes/map_button.tscn")
@onready var race_percentage_hud = $lap_percentage
@onready var position_count_hud = $position_count
@onready var race_info_hud = $race_info
@onready var lap_count_hud = $lap_count

var next_map_menu
var next_map_menu_list
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func update_race_percentage(last_checkpoint_id, checkpoints_amount):
	var length = snapped(100.0 / checkpoints_amount, 0.01)
	var race_percentage = length * (last_checkpoint_id + 1)
	var race_percentage_rounded = round(race_percentage)
	race_percentage_hud.text = str(race_percentage_rounded) + "% done"

func create_new_button(map):
	next_map_menu = get_node("next_map_menu")
	next_map_menu_list = get_node("next_map_menu/list_container")
	
	var map_choice = map.instantiate()
	var map_choice_button = map_button.instantiate()
	map_choice_button.text = map_choice.name
	map_choice_button.map_to_load = map
	map_choice_button.map_chosen.connect(_on_map_chosen)
	next_map_menu_list.add_child(map_choice_button)

func _on_map_chosen(map):
	next_map_menu.queue_free()
	get_tree().get_first_node_in_group("map_group").clear_active_map()
	get_tree().get_first_node_in_group("drivers_group").clear_active_cars()
	get_tree().get_first_node_in_group("map_group").spawn_new_map(map)

func update_positions(positions, player):
	var length = positions.size()
	positions.sort_custom(sort_descending)
	var player_position : int = 1
	for each in positions:
		if each.find(player.name) == 0:
			break
		else:
			player_position += 1
	
	var text = "Position " + str(player_position) + "/" + str(length) + "\n\n"
	
	for i in range(positions.size()):
		text += str(i+1) + ". " + positions[i][0] + "  " + str(positions[i][1]) + "\n" 
	position_count_hud.text = text

static func sort_descending(a, b):
	if a[1] > b[1]:
		return true
	return false

func update_info(info):
	race_info_hud.text = info
	
func show_map_choice():
	get_tree().get_first_node_in_group("map_list").randomize_next_map()
	
func update_lap_count(player_lap, laps):
	lap_count_hud.text = str(player_lap) + "/" + str(laps) + " laps"
