extends VehicleBody3D

var max_rpm = 1500
var max_torque = 250
@export_range(0, 1, 0.01) var acceleration : float = 1.0

var parent_follow_path : Node
var paths : Array
var random_path : Node
var spawn_point_in_path : Vector3
var movement_direction : int = 1
var next_progress_value : int

func _ready():
	parent_follow_path = get_tree().get_first_node_in_group("checkpoints")
	paths = get_tree().get_nodes_in_group("path")
	random_path = paths[randi_range(0, paths.size()-1)]
	random_path.set_progress_ratio(randf_range(0.0, 1.0))
	self.position = Vector3(random_path.position.x, random_path.position.y + 1, random_path.position.z)
	var progress = parent_follow_path.curve.get_closest_offset(self.global_position)
	
	if random_path.get_h_offset() > 0:
		movement_direction = -1
	
	next_progress_value = 10 * movement_direction
	random_path.set_progress(progress + 1 * movement_direction)
	self.look_at(random_path.position)
	self.rotation_degrees.y += 180

func _physics_process(delta):
	var progress = parent_follow_path.curve.get_closest_offset(self.global_position)
	random_path.set_progress(progress + next_progress_value)
	var target_position_in_follow = random_path.position
	
	var direction = self.global_position.direction_to(target_position_in_follow)
	var forward_vector = self.global_position.direction_to($marker.global_position)
	var angle3 = direction.angle_to(forward_vector)
	
	var angle4 = direction.signed_angle_to(forward_vector, Vector3(0,1,0))
	var half_of_pi_to_angle = PI - ( ( PI - angle3 ) / 2 )
	if sign(angle4) == -1:
		half_of_pi_to_angle = PI - half_of_pi_to_angle
	var new_angle = -float(clamp(2*sin(half_of_pi_to_angle-(PI/2)) ,-1, 1))
	
	steering = lerp(steering, new_angle * 0.4, delta * 5)
	
	var rpm = abs($back_left_wheel.get_rpm())
	$back_left_wheel.engine_force = acceleration * max_torque * ( 1 - rpm / max_rpm )	
	rpm = abs($back_right_wheel.get_rpm())
	$back_right_wheel.engine_force = acceleration * max_torque * ( 1 - rpm / max_rpm )
	
	#DrawLine3D.DrawCube(random_path.position, 1, Color(255, 0, 155, 1), 0.01)
	#DrawLine3D.DrawLine(self.global_position, target_position_in_follow, Color(255, 0, 0, 1), 0.01)
	$movement_dir_label.text = str(movement_direction)
