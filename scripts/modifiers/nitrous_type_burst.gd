extends NitrousModifier

var title : String = "LVL 1 Burst Nitrous"
var description : String = "Press [CTRL] to gain a short burst of speed. Holds 4 charges."
var icon : String = "res://textures/nitro1.png"
var used : bool = false
signal nitrous_used

func getNitrousType() -> String:
	return "burst"

func getNitrousBehaviour(car, _delta, boost_vector_direction) -> void:
	if !used:
		used = true
		var player_data = car.get_tree().get_first_node_in_group("player_data")
		var boost_to_subtract = 250
		if player_data.player_nitro_amount > 0:
			player_data.boosted(boost_to_subtract, _delta)
			car.apply_central_impulse(boost_vector_direction * 20000)
		await car.get_tree().create_timer(1).timeout
		used = false
