extends BurstNitrous

var title : String = "LVL 3 Burst Nitrous"
var description : String = "Press [CTRL] to gain a short burst of speed. Holds 6 charges."
var level : int = 3

var used : bool = false
signal nitrous_used

func _init():
	icon = "res://textures/nitro1.png"

func getNitrousType() -> String:
	return "burst"

func getNitrousBehaviour(car, delta, boost_vector_direction) -> void:
	if !used:
		used = true
		var player_data = car.get_tree().get_first_node_in_group("player_data")
		var boost_to_subtract = int(1000/6)
		var boost_particle_left = car.get_node("boost_particle_left")
		var boost_particle_right = car.get_node("boost_particle_right")
		if player_data.player_nitro_amount > 0:
			player_data.boosted(boost_to_subtract, delta)
			car.apply_central_impulse(boost_vector_direction * 28000)
			car.emit_signal("boosted", delta)
			boost_particle_left.set_lifetime(1)
			boost_particle_right.set_lifetime(1)
			boost_particle_left.set_emitting(true)
			boost_particle_right.set_emitting(true)
		await car.get_tree().create_timer(1).timeout
		boost_particle_left.set_emitting(false)
		boost_particle_right.set_emitting(false)
		used = false
	return