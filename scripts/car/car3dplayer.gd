extends "res://scripts/car/car3d.gd"

signal new_race_percentage
signal new_lap_count

func _ready():
	new_race_percentage.connect(get_tree().get_first_node_in_group("hud_group").update_race_percentage)
	new_lap_count.connect(get_tree().get_first_node_in_group("hud_group").update_lap_count)

func steer(delta) -> Array:
	var forward_vector = self.position.direction_to($marker.global_position)	
	steering = lerp(steering, Input.get_axis("right", "left") * 0.35, 5 * delta) #+ w lewo
	acceleration = Input.get_axis("back", "forward")
	
	var rpm = abs($back_left_wheel.get_rpm())
	$back_left_wheel.engine_force = acceleration * max_torque * ( 1 - rpm / max_rpm )	
	rpm = abs($back_right_wheel.get_rpm())
	$back_right_wheel.engine_force = acceleration * max_torque * ( 1 - rpm / max_rpm )
	
	if Input.is_action_just_pressed("reset"):		
		self.position = self.last_checkpoint_position
		self.position.y += 1
		self.rotation.z = 0
		self.engine_force = 0
		self.steering = 0

	return [steering, acceleration]

func collect_checkpoint(body_name):
	if (body_name == self.name):
		if self.next_checkpoint_id < checkpoints.size():
			self.last_checkpoint_position = checkpoints[self.last_checkpoint_id]
			self.next_checkpoint_id += 1
			self.last_checkpoint_id += 1
			#self.next_checkpoint_position = checkpoints[self.next_checkpoint_id]
		elif !finished:
			driver_finished_race.connect(get_tree().get_first_node_in_group("map").driver_finished_race)
			emit_signal("driver_finished_race", self)
			self.finished = true
			self.acceleration = 0

		if (self.last_checkpoint_id % self.checkpoints_in_one_lap == 1):
			self.lap_completed += 1
			emit_signal("new_lap_count", self.lap_completed, self.laps)
			
	
	emit_signal("new_race_percentage", last_checkpoint_id, checkpoints.size())

func get_speedo(delta) -> int:
	if prev_pos:
		speedo = int(transform.origin.distance_to(prev_pos) * delta * 15000)
		prev_pos = transform.origin
		get_tree().get_first_node_in_group("speedo").text = str(speedo) + " km/h"
	else:
		prev_pos = transform.origin
	return speedo
