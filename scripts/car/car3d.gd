extends VehicleBody3D

var max_rpm = 1500
var max_torque = 250
@export_range(0, 1, 0.1) var acceleration : float = 1

var prev_pos
var speedo = 0
var started = false
var starting_pos
var steering_values : Array

var starting_position
var starting_rotation

var checkpoints : Array
var checkpoints_in_one_lap : int = 1
var next_checkpoint_id : int = 1
var last_checkpoint_id : int = 0
var last_checkpoint_position : Vector3
var next_checkpoint_position
var laps : int = 1
var lap_completed : int = 0
var finished : bool = false

signal driver_finished_race

func _ready():
	$Label3D.text = self.name

func _physics_process(delta):
	var steering_values = steer(delta)
	speedo = get_speedo(delta)
	
	$steering_label.text = str(snapped(steering, 0.01))
	$lap_completed.text = "lap " + str(lap_completed)
	if started:
		set_car_position()

func set_starting_position(pos, id):
	starting_position = pos.position
	starting_rotation = pos.rotation
	self.starting_position.z += (-id * 5)
	self.starting_position.x += (-id * 3)
	last_checkpoint_position = starting_position
	started = true
	
func set_car_position():
	self.position = self.starting_position
	self.rotation = self.starting_rotation
	self.linear_velocity = Vector3(0,0,0)
	started = false

func steer(delta) -> Array:
	return steering_values

func get_speedo(delta) -> int:
	return speedo

func reset_data() -> void:
	self.finished = false
	self.lap_completed = 0
	self.next_checkpoint_id = 1
	self.last_checkpoint_id = 0
	self.acceleration = 1
	self.next_checkpoint_position = null
