extends Node

var player_race : int = 1
var player_hour : int = 9
var player_nitro_amount : int = 1000
var player_modifiers : Array[Resource]

func _ready():
	#change it to also load into the car as a scene, individual vehicle modifiers will be stored there
	#var default_nitro = load("res://scripts/modifiers/nitrous_type_burst.gd")
	#var default_perfect = load("res://scripts/modifiers/perfect_start_1_modifier.gd")
	#player_modifiers.append(default_nitro)
	#player_modifiers.append(default_perfect)
	pass

func add_new_modifier(upgrade):
	var resourced_upgrade = upgrade.new()
	if resourced_upgrade.has_method("getNitrousType"):
		for existing_mod in player_modifiers:
			var resourced_mod = existing_mod.new()
			if resourced_mod.has_method("getNitrousType"):
				player_modifiers.erase(existing_mod)
	if resourced_upgrade.has_method("showPerfectStart"):
		for existing_mod in player_modifiers:
			var resourced_mod = existing_mod.new()
			if resourced_mod.has_method("showPerfectStart"):
				player_modifiers.erase(existing_mod)
	player_modifiers.append(upgrade)

func clear_data():
	player_race = 1
	player_hour = 9
	player_modifiers.clear()
	get_tree().get_first_node_in_group("environment_group").change_environment(player_hour)
	get_tree().get_first_node_in_group("hud_group").update_player_race(player_race, player_hour)

func update_player_race():
	player_race += 1
	player_hour += 3
	player_nitro_amount = 1000
	get_tree().get_first_node_in_group("environment_group").change_environment(player_hour)
	get_tree().get_first_node_in_group("hud_group").update_player_race(player_race, player_hour)
	get_tree().get_first_node_in_group("hud_group").update_player_boost(player_nitro_amount)

func boosted(boost_to_subtract, _delta):
	player_nitro_amount -= boost_to_subtract
	get_tree().get_first_node_in_group("hud_group").update_player_boost(player_nitro_amount)

