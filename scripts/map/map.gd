extends Node3D

@onready var starting_position = $starting_position
@onready var map_path_checkpoints = $checkpoints
@onready var player_car = preload("res://scenes/car.tscn")
@onready var enemy_ai_car = preload("res://scenes/carAI.tscn")

var checkpoints : Array
var checkpoints_in_one_lap : int
var length : int
var laps : int
var enemies : int
var player : Node
var drivers : Array[Node]
var map_length : int
var race_in_process : bool = false
var results : Array

signal camera_follow
signal camera_reset
signal update_positions
signal update_info
signal show_map_choice


func _ready():
	race_in_process = false
	self.add_to_group("map")
	update_info.connect(get_tree().get_first_node_in_group("hud_group").update_info)
	emit_signal("update_info", " ")
	
	checkpoints = map_path_checkpoints.get_checkpoint_list(laps)
	#checkpoints.reverse()
	checkpoints_in_one_lap = (map_path_checkpoints.get_checkpoint_list(1)).size()
	map_path_checkpoints.load_checkpoint_instances(checkpoints)
	
	var player_name = "fuczek"
	instantiate_player(player_name)
	var ai_names = ["sheo", "pliszkar", "gimbus", "naganiacz"]
	instantiate_ai_drivers(ai_names)
	
	if drivers:
		drivers.clear()
	player = get_tree().get_first_node_in_group("player")
	drivers = get_tree().get_nodes_in_group("driver")
	
	if player:
		camera_follow.connect(get_tree().get_first_node_in_group("camera_group").find_car)
		emit_signal("camera_follow", player)
	
	#check positions
	map_length = map_path_checkpoints.curve.get_baked_length()
	update_positions.connect(get_tree().get_first_node_in_group("hud_group").update_positions)
	
	
func _process(delta):
	var driver_positions : Array[Array]
	for driver in drivers:
		if !driver.is_in_group("player"):
			driver_positions.append([driver.name, snapped(map_path_checkpoints.curve.get_closest_offset(driver.position), 0)])
		else:
			driver_positions.append([player.name, snapped(map_path_checkpoints.curve.get_closest_offset(player.position), 0)])
	emit_signal("update_positions", driver_positions, player)


func instantiate_player(player_name):
	var player = player_car.instantiate()
	player.name = player_name
	player.set_starting_position(starting_position, 0)
	player.checkpoints = checkpoints
	player.laps = laps
	player.checkpoints_in_one_lap = checkpoints_in_one_lap
	get_tree().get_first_node_in_group("drivers_group").add_child(player)


func instantiate_ai_drivers(ai_names):
	for n in enemies:
		var enemy = enemy_ai_car.instantiate()
		enemy.name = ai_names[n]
		enemy.set_starting_position(starting_position, n+1)
		enemy.checkpoints = checkpoints
		enemy.acceleration = 0.9
		enemy.checkpoints_in_one_lap = checkpoints_in_one_lap
		get_tree().get_first_node_in_group("drivers_group").add_child(enemy)


func driver_finished_race(racer):
	if (racer.name == player.name):
		results.append(racer.name)
		var info_text = "Race finished.\nFinished " + str(results.size()) + "."
		emit_signal("update_info", info_text)
		camera_reset.connect(get_tree().get_first_node_in_group("camera_group").reset)
		emit_signal("camera_reset")
		await get_tree().create_timer(1).timeout
		show_map_choice.connect(get_tree().get_first_node_in_group("hud_group").show_map_choice)
		emit_signal("show_map_choice")
	else:
		results.append(racer.name)
