extends Node
@export var default_modifiers : Array[Resource]
var actual_modifiers : Array[Resource]

signal map_loaded
signal new_lap_count

var laps : int = 3
var enemies : int = 0
var player_lap : int = 1
var checkpoints : Array
var length : float = 0
var race_rewards : Array[Resource]

func _ready():
	new_lap_count.connect(get_tree().get_first_node_in_group("hud_group").update_lap_count)

func _process(delta):
	pass

func clear_active_map():
	var children_list = self.get_children()
	if children_list:
		var traffic_group = get_tree().get_first_node_in_group("traffic_group")
		var traffic_list = traffic_group.get_children()
		if traffic_group.get_children():
			for node in traffic_list:
				node.queue_free()
	
		for node in children_list:
			node.queue_free()

func spawn_new_map(map):
	map.laps = laps
	map.enemies = enemies
	self.add_child(map)

func update_modifiers(modifiers):
	for modifier in modifiers:
		var mod = modifier.new()

		#lap count modifier
		if mod != null and mod.has_method("getLapCount"):
			laps = mod.getLapCount()
			emit_signal("new_lap_count", player_lap, laps)

		#enemy count modifier
		if mod != null and mod.has_method("getEnemyCount"):
			enemies = mod.getEnemyCount()

func update_rewards(rewards):
	race_rewards.clear()
	
	var available_upgrades = get_tree().get_first_node_in_group("upgrade_list").available_upgrades_default
	print(rewards.icon)
	print("rewards:", rewards, "available:", available_upgrades)
	if rewards != null and rewards.has_method("getNitrousType"):
		for upgrade in available_upgrades:
			var upgr = upgrade.new()
			if upgr != null and upgr.has_method("getNitrousType"):
				race_rewards.append(upgrade)
		return
				
	elif rewards != null and rewards.has_method("perfectStart"):
		for upgrade in available_upgrades:
			var upgr = upgrade.new()
			if upgr != null and upgr.has_method("perfectStart"):
				race_rewards.append(upgrade)
		return
				
	elif rewards != null and rewards.has_method("isAbility"):
		for upgrade in available_upgrades:
			var upgr = upgrade.new()
			print(upgr.title)
			if upgr != null and upgr.has_method("isAbility"):
				race_rewards.append(upgrade)
		return
				
	elif rewards != null and rewards.has_method("isNone"):
		race_rewards.clear()
		return
	
	
