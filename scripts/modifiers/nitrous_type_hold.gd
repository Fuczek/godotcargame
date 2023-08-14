extends NitrousModifier

var title = "LVL 1 Hold Nitrous"
var description = "Hold [CTRL] to gain speed. Holds 5 seconds of charge."
var icon = "res://textures/nitro2.png"
signal nitrous_used

func getNitrousType() -> String:
	return "hold"

func getNitrousBehaviour(car, _delta, boost_vector_direction) -> void:
	var player_data = car.get_tree().get_first_node_in_group("player_data")
	var boost_to_subtract = 10
	if player_data.player_nitro_amount > 0:
		player_data.boosted(boost_to_subtract, _delta)
		car.apply_central_impulse(boost_vector_direction * 1500)
