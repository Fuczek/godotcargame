extends HoldNitrous

var title = "LVL 3 Hold Nitrous"
var description = "Hold [CTRL] to gain speed. Holds 10 seconds of charge."
var level : int = 3

signal nitrous_used

func _init():
	icon = "res://textures/nitro2.png"
	
func getNitrousType() -> String:
	return "hold"

func getNitrousBehaviour(car, delta, boost_vector_direction) -> void:
	var player_data = car.get_tree().get_first_node_in_group("player_data")
	var boost_to_subtract = 6
	var boost_particle_left = car.get_node("boost_particle_left")
	var boost_particle_right = car.get_node("boost_particle_right")
	if player_data.player_nitro_amount > 0:
		player_data.boosted(boost_to_subtract, delta)
		car.apply_central_impulse(boost_vector_direction * 1100)
		boost_particle_left.set_one_shot(true)
		boost_particle_right.set_one_shot(true)
		boost_particle_left.set_emitting(true)
		boost_particle_right.set_emitting(true)
		car.emit_signal("boosted", delta)
	return
