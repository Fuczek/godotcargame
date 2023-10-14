extends VehicleBody3D

@export var rpm_curve : Curve = preload("res://rpm_curve.tres")
@export var vehicle_modifiers : Array[Resource]

@export var MAX_ENGINE_FORCE = 700.0
@export var MAX_BRAKE_FORCE = 50.0

@export var drive_ratios : Array = [3.0, 2.67, 2.01, 1.59, 1.32, 1.13, 1.1]
@export var reverse_ratio : float = 2.5
@export var final_drive_ratio : float = 3.38
@export var wheel_radius : float = 0.4 #meters

var current_gear : int = 0
var speedo : float = 0.0
var default_rpms : float = 1000
var current_rpms : float = default_rpms
var maximum_rpms : float = 8000
var calculated_rpm : float

var max_rpm = 1500
var max_torque = 250
@export_range(0, 1, 0.1) var acceleration : float = 1

var prev_pos
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

var nitrous_ready : bool = true

var replay_duration: float = 3.0
var rewinding: bool = false
var rewind_values = {
	"transform": [],
	"linear_velocity": [],
	"angular_velocity": [],
	"calculated_rpm": [],
	"gear": [],
}

signal driver_finished_race

func _ready():
	$name.text = self.name

func _physics_process(delta):
	var steering_values = steer(delta)
	speedo = get_speedo(delta)
	
	if rewinding:
		angular_velocity = Vector3.ZERO
		linear_velocity = Vector3.ZERO
		return [0, 0]

	if not rewinding:
		if replay_duration * Engine.physics_ticks_per_second == rewind_values["transform"].size():
			for key in rewind_values.keys():
				rewind_values[key].pop_front()
		
		rewind_values["transform"].append(global_transform)
		rewind_values["linear_velocity"].append(linear_velocity)
		rewind_values["angular_velocity"].append(angular_velocity)
		rewind_values["calculated_rpm"].append(calculated_rpm)
		rewind_values["gear"].append(current_gear)
	
	$steering_label.text = str(snapped(steering, 0.01))
	$lap_completed.text = "lap " + str(lap_completed)
	
	if started:
		set_car_position()

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if not rewinding: return
	compute_rewind(state)

func compute_rewind(state: PhysicsDirectBodyState3D) -> void:
	var transf = rewind_values["transform"].pop_back()
	var linear_vel = rewind_values["linear_velocity"].pop_back()
	var angular_vel = rewind_values["angular_velocity"].pop_back()
	var calc_rpm = rewind_values["calculated_rpm"].pop_back()
	var gear = rewind_values["gear"].pop_back()
	
	if rewind_values["transform"].is_empty():
		#$CollisionShape3D.set_deferred("disabled", false)
		rewinding = false
		
		#print(linear_vel, angular_vel)
		state.linear_velocity = linear_vel
		state.angular_velocity = angular_vel
		state.transform = transf
		state.transform.origin.y = transf.origin.y
		current_gear = gear
		return
	
	state.transform = transf
	state.linear_velocity = Vector3.ZERO
	state.angular_velocity = Vector3.ZERO
	current_gear = gear

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
