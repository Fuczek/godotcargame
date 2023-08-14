extends Node3D

@onready var camera : Node = $inner_gimbal/camera
var car : Node
var marker
var follow : bool = false
var boosted: bool = false

func _process(delta):
	if follow:
		follow_car(delta)
		
	if boosted:
		boost_effect(delta)
	else:
		boost_finished(delta)

func follow_car(delta):
	var translation_distance = 0.0
	var car_speed = car.speedo
	var car_rotation = car.global_rotation
	translation_distance = snapped(car_speed * 0.01, 0.01)

	#4 10 4
	#var new_cam_pos = lerp(self.position, Vector3(car.global_transform.origin.x, car.global_transform.origin.y + 3 + translation_distance, car.global_transform.origin.z + -2 - translation_distance), 0.5)
	var new_cam_pos = lerp(self.position, Vector3(car.global_transform.origin.x, car.global_transform.origin.y, car.global_transform.origin.z), 0.5)
	var new_cam_rot = lerp(self.rotation_degrees, Vector3(self.rotation_degrees.x, car.rotation_degrees.y, self.rotation_degrees.z), 0.5) 
	self.position = new_cam_pos
	self.rotation_degrees = new_cam_rot

func find_car(car_node):
	car = get_tree().get_first_node_in_group("player")
	marker = car.get_node("marker")
	follow = true

func reset():
	follow = false

func boost_effect(delta):
	boosted = true
	var camera_fov = camera.get_fov()
	var boost_camera_fov = 90.0
	var new_camera_fov = lerp(camera_fov, boost_camera_fov, 10 * delta)
	camera.set_fov(new_camera_fov)
	await get_tree().create_timer(1).timeout
	boosted = false
	
func boost_finished(delta):
	var camera_fov = camera.get_fov()
	var normal_camera_fov = 70.0
	var new_camera_fov = lerp(camera_fov, normal_camera_fov, 0.5 * delta)
	camera.set_fov(new_camera_fov)
