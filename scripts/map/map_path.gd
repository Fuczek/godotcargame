extends Path3D

@onready var checkpoint = preload('res://scenes/checkpoint.tscn')

func _ready():
	pass
	#spawn_next_checkpoint()

func get_checkpoint_list(laps):
	var checkpoint_list : Array
	for i in laps:
		for id in curve.get_point_count():
			checkpoint_list.append(curve.get_point_position(id))
	return checkpoint_list
	
func load_checkpoint_instances(checkpoint_list):
	for id in range(checkpoint_list.size()):
		var checkpoint_instance = checkpoint.instantiate()
		var location_to_spawn_next_checkpoint : Vector3 = checkpoint_list[id]
		checkpoint_instance.name = str(id+1)
		checkpoint_instance.position = location_to_spawn_next_checkpoint
		self.add_child(checkpoint_instance)
		if (id+1 == checkpoint_list.size()):
			checkpoint_instance.look_at(checkpoint_list[0], Vector3(0, 1, 0))
		else:
			checkpoint_instance.look_at(checkpoint_list[id+1], Vector3(0, 1, 0))
		checkpoint_instance.rotation.x = 0

#func _start_lap():
#	for id in curve.get_point_count():
#		checkpoint_list.append(curve.get_point_position(id))
#
#func spawn_next_checkpoint():
#	var next_checkpoint = checkpoint.instantiate()
#	next_checkpoint.add_to_group("checkpoint")
#	if (next_checkpoint_id < checkpoint_list.size()):
#		next_checkpoint.position = checkpoint_list[next_checkpoint_id]
#		add_child(next_checkpoint)
#		if (next_checkpoint_id-1 > 0):
#			next_checkpoint.look_at(checkpoint_list[next_checkpoint_id-1], Vector3.UP)
#		else:
#			next_checkpoint.look_at(checkpoint_list[-1], Vector3.UP)
#		next_checkpoint_id += 1
#	else:
#		checkpoint_list.clear()
