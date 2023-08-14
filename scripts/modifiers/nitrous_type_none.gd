extends LapModifier

signal nitrous_used
var title = "None Nitrous"
var description = "description1"
var icon = "res://textures/icon.svg"

var used = false

func getNitrousType() -> String:
	return "none"

func getNitrousBehaviour(car, _delta, boost_vector_direction) -> void:
	return
