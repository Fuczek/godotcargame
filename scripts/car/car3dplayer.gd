extends "res://scripts/car/car3d.gd"

signal new_race_percentage
signal new_lap_count
signal boosted
signal update_player_boost
signal update_rpm
signal perfect_rpm_range
signal clear_modifiers_in_hud
signal add_modifier_in_hud
signal update_modifier_uses
signal update_info

var reset_count = 0
var time_to_reset = 60
var can_reset = true
var reset_value_before = true

func _ready():
	new_race_percentage.connect(get_tree().get_first_node_in_group("hud_group").update_race_percentage)
	new_lap_count.connect(get_tree().get_first_node_in_group("hud_group").update_lap_count)
	boosted.connect(get_tree().get_first_node_in_group("camera_group").boost_effect)
	update_rpm.connect(get_tree().get_first_node_in_group("hud_group").update_rpms)
	perfect_rpm_range.connect(get_tree().get_first_node_in_group("hud_group").perfect_rpm_range)
	add_modifier_in_hud.connect(get_tree().get_first_node_in_group("hud_group").add_modifier_in_hud)
	update_modifier_uses.connect(get_tree().get_first_node_in_group("hud_group").update_modifier_uses)
	update_player_boost.connect(get_tree().get_first_node_in_group("hud_group").update_player_boost)
	update_info.connect(get_tree().get_first_node_in_group("hud_group").update_info)
	get_nitrous_type()
	get_perfect_start()
	get_rewind_ability()
	get_restart_ability()
	clear_modifiers_in_hud.connect(get_tree().get_first_node_in_group("hud_group").clear_modifiers_in_hud)
	emit_signal("clear_modifiers_in_hud")
	get_all_modifiers()
	get_tree().get_first_node_in_group("player_data").player_nitro_amount = 1000

var rewindAbility
var rewinds_remaining

func steer(delta) -> Array:
	if Input.is_action_just_pressed("rewind"):
		if rewindAbility:
			var drivers = get_parent().get_children()
			rewinds_remaining = rewindAbility.rewind(drivers, rewinds_remaining)
			emit_signal("update_modifier_uses", self, rewindAbility, rewinds_remaining)
			get_tree().get_first_node_in_group("player_data").update_player_rewinds(rewinds_remaining)
		else:
			print('not unlocked')

	var forward_vector = self.position.direction_to($marker.global_position)
	steering = lerp(steering, Input.get_axis("right", "left") * 0.5, 2 * delta) #+ w lewo
	acceleration = Input.get_axis("back", "forward")
		
	calculated_rpm = calculate_rpm()
	#print(calculated_rpm)
	var rpm_factor = clamp(calculated_rpm / maximum_rpms, 0.0, 1.0)
	var power_factor = rpm_curve.sample(rpm_factor)
	
	if current_gear == -1:
		engine_force = acceleration * power_factor * reverse_ratio * final_drive_ratio * MAX_ENGINE_FORCE
	elif current_gear > 0 and current_gear <= drive_ratios.size():
		engine_force = acceleration * power_factor *  drive_ratios[current_gear - 1] * final_drive_ratio * MAX_ENGINE_FORCE
	else:
		engine_force = 0.0
	
	#print(engine_force)
	#perfect start boost
	if perfectStart:
		var isInRangeOfPerfectStart = perfectStart.showPerfectStart(rev_rpm, current_gear)
		perfectStart.getBehaviour(self, delta, forward_vector)
		emit_signal('perfect_rpm_range', isInRangeOfPerfectStart)
		#print(isInRangeOfPerfectStart)
		if current_gear > 1 and !perfectStartRemoved:
			perfectStart.removePerfectStartBoost(self)
			perfectStartRemoved = true
	
	if calculated_rpm > 6200:
		current_gear += 1
	
	if Input.is_action_just_pressed("gear_down") and current_gear > -1:
		current_gear -= 1
	elif Input.is_action_just_pressed("gear_up") and current_gear < drive_ratios.size() - 1:
		current_gear += 1
		
	#print(int(engine_force), ", rpms: ", int(calculated_rpm), " gear: ", current_gear)
	emit_signal("update_rpm", calculated_rpm, current_gear)
	
	
	if Input.is_action_pressed("reset") and can_reset:
		reset_count += 1
		
		if reset_count > time_to_reset:
			calculated_rpm = default_rpms
			current_gear = 0
			self.position = self.last_checkpoint_position
			self.look_at(self.next_checkpoint_position, Vector3(0, -1, 0))
			self.rotation_degrees.y += 180
			self.position.y += 1
			self.rotation.z = 0
			self.engine_force = 0
			self.steering = 0
			self.linear_velocity = Vector3.ZERO
			self.angular_velocity = Vector3.ZERO
			self.apply_central_impulse(forward_vector * 40000)
			can_reset = false
			reset_count = 0
			
	elif !can_reset:
		reset_count += 1
		if reset_count > time_to_reset:
			can_reset = true
	else:
		reset_count = 0
		
	if Input.is_action_pressed("boost") and nitrousType:
		var boost_vector_direction = self.position.direction_to($marker.global_position)
		nitrousType.getNitrousBehaviour(self, delta, boost_vector_direction)
	
	if Input.is_action_just_pressed("lose_debug"):
		driver_finished_race.connect(get_tree().get_first_node_in_group("map").driver_finished_race)
		emit_signal("driver_finished_race", self, 4)
	
	if Input.is_action_just_pressed("win_debug"):
		driver_finished_race.connect(get_tree().get_first_node_in_group("map").driver_finished_race)
		emit_signal("driver_finished_race", self)
		
	return [steering, acceleration]

var speedo2 = 0.0
var rev_rpm : float = 0.0

func calculate_rpm() -> float:
	var wheel_circumference : float = 2.0 * PI * wheel_radius
	var wheel_rotation_speed : float
	if current_gear == 0 and acceleration != 0:
		speedo2 += 2.0
		wheel_rotation_speed = 20.0 * speedo2 / wheel_circumference
	elif current_gear == 0:
		speedo2 -= 0.5
		speedo2 = clamp(speedo2, 0, maximum_rpms)
		wheel_rotation_speed = 20.0 * speedo2 / wheel_circumference
	else:
		wheel_rotation_speed = 20.0 * speedo / wheel_circumference
	var drive_shaft_rotation_speed : float = wheel_rotation_speed * final_drive_ratio
	if current_gear == -1:
		return drive_shaft_rotation_speed * -reverse_ratio
	elif current_gear == 0:
		rev_rpm = drive_shaft_rotation_speed * drive_ratios[0]
		return drive_shaft_rotation_speed * drive_ratios[0]
	elif current_gear < drive_ratios.size() - 1:
		#print(drive_shaft_rotation_speed * drive_ratios[current_gear], " GEAR:", drive_ratios[current_gear])
		return drive_shaft_rotation_speed * drive_ratios[current_gear]
	else:
		return 0.0

func collect_checkpoint(body_name, checkpoint_position):
	if (body_name == self.name):
		if self.next_checkpoint_id < checkpoints.size():
			self.last_checkpoint_position = Vector3(checkpoint_position.x, checkpoint_position.y + 0.02, checkpoint_position.z)
			self.next_checkpoint_position = checkpoints[self.next_checkpoint_id]
			self.next_checkpoint_id += 1
			self.last_checkpoint_id += 1
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
	
var perfectStart
var perfectStartRemoved

var restartAbility
var restarts_remaining

func get_restart_ability():
	var modifiers = get_tree().get_first_node_in_group("player_data").player_modifiers
	for modifier in modifiers:
		var mod = modifier.new()
		if mod != null and mod.has_method("restart"):
			restartAbility = mod
			restarts_remaining = get_tree().get_first_node_in_group("player_data").player_restarts_remaining

func get_rewind_ability():
	var modifiers = get_tree().get_first_node_in_group("player_data").player_modifiers
	for modifier in modifiers:
		var mod = modifier.new()
		if mod != null and mod.has_method("rewind"):
			rewindAbility = mod
			rewinds_remaining = get_tree().get_first_node_in_group("player_data").player_rewinds_remaining

func get_perfect_start():
	var modifiers = get_tree().get_first_node_in_group("player_data").player_modifiers
	for modifier in modifiers:
		var mod = modifier.new()
		if mod != null and mod.has_method("showPerfectStart"):
			perfectStart = mod

var nitrousType
func get_nitrous_type():
	var modifiers = get_tree().get_first_node_in_group("player_data").player_modifiers
	for modifier in modifiers:
		var mod = modifier.new()
		if mod != null and mod.has_method("getNitrousType"):
			nitrousType = mod
			emit_signal("update_player_boost", get_tree().get_first_node_in_group("player_data").player_nitro_amount)

func get_all_modifiers():
	var modifiers = get_tree().get_first_node_in_group("player_data").player_modifiers
	for modifier in modifiers:
		var mod = modifier.new()
		if mod.has_method("isAbility"):
			emit_signal("add_modifier_in_hud", mod.title, mod.icon, mod.level, mod.uses)
			if mod.has_method("restart"):
				emit_signal("update_modifier_uses", self, mod, get_tree().get_first_node_in_group("player_data").player_restarts_remaining)
			if mod.has_method("rewind"):
				emit_signal("update_modifier_uses", self, mod, get_tree().get_first_node_in_group("player_data").player_rewinds_remaining)
		else:
			emit_signal("add_modifier_in_hud", mod.title, mod.icon, mod.level, null)
		vehicle_modifiers.append(modifier)
