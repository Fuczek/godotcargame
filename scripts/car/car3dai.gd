extends "res://scripts/car/car3d.gd"

var angle3
var new_angle
var slow : float = 0
var resetting : bool = false

func steer(delta) -> Array:
	#set checkpoint
	if (checkpoints.size() > 0 and self.next_checkpoint_position == null):
		self.collect_checkpoint(self.name)
		
	#go to next checkpoint
	var direction	
	var debug_vector = Vector3(0, self.position.y, 0)
	if self.next_checkpoint_position:
		direction = self.position.direction_to(self.next_checkpoint_position)
		var forward_vector = self.position.direction_to($marker.global_position)
		angle3 = direction.angle_to(forward_vector) #good
		var angle4 = direction.signed_angle_to(forward_vector, Vector3(0,1,0))
		
		var half_of_pi_to_angle = PI - ( ( PI - angle3 ) / 2 )
		if sign(angle4) == -1:
			half_of_pi_to_angle = PI - half_of_pi_to_angle

		
		
		new_angle = -float(clamp(2*sin(half_of_pi_to_angle-(PI/2)) ,-1, 1))

		#print(new_angle, "  ", half_of_pi_to_angle, "   ", rad_to_deg(angle3), "|| angle3: ", angle3, "  ", new_angle, "  ")
		DrawLine3D.DrawLine(self.position, self.next_checkpoint_position, Color(255, 0, 0, 1), 0.01)
		#DrawLine3D.DrawLine(self.position, $marker.global_position, Color(0, 0, 3, ), 0.01) #vector pointing forward
		
		if (snapped(steering, 0.01) >= snapped(0.34, 0.01)) or (snapped(steering, 0.01) <= snapped(-0.34, 0.01)):
			self.slow += 1
		else:
			self.slow = 0
		
		
		if self.slow > 40:
			#print(self.name, 'steering max')
			steering = lerp(steering, new_angle * 1, delta * 5)
		else:
			steering = lerp(steering, new_angle * 0.35, delta * 5)
			#print(self.name, 'steering normal')
		#go maximum until the angle is 0

	if abs(self.rotation_degrees.z) > 45 and !self.resetting:
		reset_car()
		

	var rpm = abs($back_left_wheel.get_rpm())
	$back_left_wheel.engine_force = acceleration * max_torque * ( 1 - rpm / max_rpm )	
	rpm = abs($back_right_wheel.get_rpm())
	$back_right_wheel.engine_force = acceleration * max_torque * ( 1 - rpm / max_rpm )
	
	return [steering, acceleration]

func collect_checkpoint(body_name):
	if (body_name == self.name):
		if self.next_checkpoint_id < checkpoints.size():
			self.last_checkpoint_position = checkpoints[self.last_checkpoint_id]
			self.next_checkpoint_position = checkpoints[self.next_checkpoint_id] + Vector3(randf_range(-2, 2), 0, randf_range(-2, 2))
			self.next_checkpoint_id += 1
			self.last_checkpoint_id += 1
			self.slow = 0
		elif !finished:
			driver_finished_race.connect(get_tree().get_first_node_in_group("map").driver_finished_race)
			emit_signal("driver_finished_race", self)
			self.finished = true
			self.acceleration = 0
		
		#print(last_checkpoint_id, " ", checkpoints_in_one_lap, " ", last_checkpoint_id % checkpoints_in_one_lap)
		if (self.last_checkpoint_id % self.checkpoints_in_one_lap == 1):
			self.lap_completed += 1

func reset_car():
	self.resetting = true
	$information_label.text = "Resetting.."
	await get_tree().create_timer(3).timeout
	if abs(self.rotation_degrees.z) > 45:
		self.position = self.last_checkpoint_position
		self.position.y += 1
		self.rotation.z = 0
		self.engine_force = 0
		self.steering = 0
		
	self.resetting = false
	$information_label.text = ""
