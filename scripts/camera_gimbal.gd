extends Node3D

var car : Node
var marker
var follow : bool = false

func _process(delta):
	if follow:
		follow_car(delta)

func follow_car(delta):
	var translation_distance = 0.0
	var car_speed = car.speedo
	var car_rotation = car.global_rotation
	translation_distance = snapped(car_speed * 0.01, 0.01)

	var new_cam_pos = lerp(self.position, Vector3(car.global_transform.origin.x + 4, car.global_transform.origin.y + 10 + translation_distance, car.global_transform.origin.z + 4), 0.5) 
	self.position = new_cam_pos

func find_car(car_node):
	car = get_tree().get_first_node_in_group("player")
	marker = car.get_node("marker")
	follow = true

func reset():
	follow = false
