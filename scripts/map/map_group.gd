extends Node
@export var modifiers : Array[Resource]

signal map_loaded
signal new_lap_count

var laps : int = 3
var enemies : int = 1
var player_lap : int = 1
var checkpoints : Array
var length : float = 0

func _ready():
	#get modifiers that will be applied in the next map
	for modifier in modifiers:
		var mod = modifier.new()
		
		#lap count modifier
		if mod != null and mod.has_method("getLapCount"):
			laps = mod.getLapCount()
			new_lap_count.connect(get_tree().get_first_node_in_group("hud_group").update_lap_count)
			emit_signal("new_lap_count", player_lap, laps)
		
		#enemy count modifier
		if mod != null and mod.has_method("getEnemyCount"):
			enemies = mod.getEnemyCount()
		
func _process(delta):
	pass

func clear_active_map():
	var children_list = self.get_children() 
	if self.get_children():
		for node in children_list:
			node.queue_free()

func spawn_new_map(map):
	map.laps = laps
	map.enemies = enemies
	self.add_child(map)
