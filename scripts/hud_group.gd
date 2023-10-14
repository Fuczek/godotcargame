extends Control

@onready var map_button = preload("res://scenes/map_button.tscn")
@onready var upgrade_button = preload("res://scenes/upgrade_button.tscn")
@onready var modifier_icon = preload("res://scenes/modifier_icon.tscn")
@onready var restart_menu = preload("res://scenes/restart_menu.tscn")
@onready var race_percentage_hud = $lap_percentage
@onready var position_count_hud = $position_count
@onready var race_info_hud = $race_info
@onready var lap_count_hud = $lap_count
@onready var race_count_hud = $race_count
@onready var nitrous_bar_hud = $nitrous_bar
@onready var rpm_bar = $rpm_bar
@onready var rpm_value = $rpm_value
@onready var modifiers_list = $modifiers_list
@onready var boss_fight_bar = $boss_fight_bar
@onready var boss_fight_name = $boss_fight_bar/boss_name

var next_upgrade_menu
var next_upgrade_menu_list
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

func create_new_upgrade_button(upgrade):
	next_upgrade_menu = get_node("next_upgrade_menu")
	next_upgrade_menu_list = get_node("next_upgrade_menu/list_container")
	var upgrade_choice = upgrade.new()
	var upgrade_choice_button = upgrade_button.instantiate()
	#print(upgrade_choice)
	var title = upgrade_choice.title
	var description = upgrade_choice.description
	var icon = upgrade_choice.icon

	#for modifier in modifiers:
#		var mod = modifier.new()
#		if mod != null and mod.has_method("getLapCount"):
#			text += "\nLaps: " + str(mod.getLapCount())
#		if mod != null and mod.has_method("getEnemyCount"):
#			text += "\nEnemies: " + str(mod.getEnemyCount())
		
	upgrade_choice_button.title = title
	upgrade_choice_button.description = description
	upgrade_choice_button.icon = icon
	upgrade_choice_button.upgrade_to_load = upgrade
	#map_choice_button.modifiers_to_load = modifiers
	upgrade_choice_button.upgrade_chosen.connect(_on_upgrade_chosen)
	next_upgrade_menu_list.add_child(upgrade_choice_button)

func _on_upgrade_chosen(upgrade):
	#player_data zmienic modifiery gracza czy cos tam
	next_upgrade_menu.queue_free()
	get_tree().get_first_node_in_group("player_data").update_uses_remaining(upgrade)
	get_tree().get_first_node_in_group("player_data").add_new_modifier(upgrade)
	get_tree().get_first_node_in_group("map").connect_show_map_choice()

func create_new_button(map, modifiers, reward_script, reward_icon):
	next_map_menu = get_node("next_map_menu")
	next_map_menu_list = get_node("next_map_menu/list_container")
	var map_choice = map.instantiate()
	var map_choice_button = map_button.instantiate()
	var text = map_choice.name + "\n"
	for modifier in modifiers:
		var mod = modifier.new()
		if mod != null and mod.has_method("getLapCount"):
			text += "\nLaps: " + str(mod.getLapCount())
		if mod != null and mod.has_method("getEnemyCount"):
			text += "\nEnemies: " + str(mod.getEnemyCount())
		
	map_choice_button.text = text
	map_choice_button.map_to_load = map
	map_choice_button.modifiers_to_load = modifiers
	map_choice_button.map_chosen.connect(_on_map_chosen)
	map_choice_button.reward_icon_to_load = reward_icon
	map_choice_button.rewards = reward_script
	next_map_menu_list.add_child(map_choice_button)

func _on_map_chosen(map, modifiers, rewards):
	next_map_menu.queue_free()
	get_tree().get_first_node_in_group("map_group").clear_active_map()
	get_tree().get_first_node_in_group("drivers_group").clear_active_cars()
	get_tree().get_first_node_in_group("map_group").update_rewards(rewards)
	get_tree().get_first_node_in_group("map_group").update_modifiers(modifiers)
	get_tree().get_first_node_in_group("map_group").spawn_new_map(map)

func update_positions(positions, player, player_target):
	var length = positions.size()
	positions.sort_custom(sort_descending)
	var player_position : int = 1
	for each in positions:
		if each.find(player.name) == 0:
			break
		else:
			player_position += 1
	
	var text = "Position " + str(player_position) + "/" + str(length) + "\nTARGET: " + str(player_target) + "\n"
	
	for i in range(positions.size()):
		text += str(i+1) + ". " + positions[i][0] + "  " + str(positions[i][1]) + "\n" 
	position_count_hud.text = text

static func sort_descending(a, b):
	if a[1] > b[1]:
		return true
	return false

func update_info(info):
	#print(info)
	race_info_hud.text = info
	await get_tree().create_timer(3).timeout
	race_info_hud.text = ""
	
func show_upgrade_choice():
	get_tree().get_first_node_in_group("upgrade_list").randomize_next_upgrade(false)

func show_map_choice():
	get_tree().get_first_node_in_group("map_list").randomize_next_map(false)
	
func update_lap_count(player_lap, laps):
	lap_count_hud.text = str(player_lap) + "/" + str(laps) + " laps"
	
func update_player_race(player_race, player_hour):
	race_count_hud.text = "Race: " + str(player_race)
	race_count_hud.text += "\n" + player_hour

func update_rpms(rpms, current_gear):
	rpm_bar.value = int(rpms)
	rpm_value.text = str(current_gear) + "   " + str(int(rpms))

func perfect_rpm_range(perfect_range):
	if perfect_range:
		rpm_bar.texture_progress = load("res://textures/grass.jpg")
	else:
		rpm_bar.texture_progress = load("res://textures/red.jpg")

func update_player_boost(player_nitro_amount):
	nitrous_bar_hud.text = str(player_nitro_amount) + " BOOST LEFT"

func restart_game():
	var instantiated_menu = restart_menu.instantiate()
	add_child(instantiated_menu)

func clear_modifiers_in_hud():
	var modifiers_to_clear = modifiers_list.get_children()
	for each in modifiers_to_clear:
		each.queue_free()

func add_modifier_in_hud(title, icon, level, uses):
	var icon_instance = modifier_icon.instantiate()
	var icon_image = load(icon).get_image()
	icon_instance.texture = ImageTexture.create_from_image(icon_image)
	if uses:
		icon_instance.uses = get_tree().get_first_node_in_group("player_data").player_rewinds_remaining
	else:
		icon_instance.level = level
	icon_instance.name = title
	#icon_texture.resize(128, 128, 1)
	modifiers_list.add_child(icon_instance)

func update_modifier_uses(player, ability, uses):
	for mod in modifiers_list.get_children():
		var mod_name = mod.name
		if ability.title in mod_name:
			mod.update_values(uses)
	return

func enable_boss_hud(map_length, boss_name):
	boss_fight_bar.set_visible(true)
	boss_fight_name.set_visible(true)
	boss_fight_bar.max_value = int(map_length)
	boss_fight_name.text = boss_name

func disable_boss_hud():
	boss_fight_bar.hide()
	boss_fight_name.hide()
	#print('chuj')

func update_boss_hud(player_position):
	boss_fight_bar.value = player_position
