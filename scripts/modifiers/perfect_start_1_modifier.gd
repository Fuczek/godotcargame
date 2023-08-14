extends PerfectStartModifier

var title = "LVL 1 Perfect Start"
var description = "Allows the vehicle to gain a boost of speed when in optimal revs."
var icon = "res://textures/perfectstart1.png"

var minPerfectValue = 5000
var maxPerfectValue = 7000
var perfectStartBoost = 0.2
signal perfect_rpm_range

func getBehaviour(car, _delta, forward_vector) -> void:
	if car.current_gear == 1 and ( (car.rev_rpm > minPerfectValue and car.rev_rpm < maxPerfectValue) and car.speedo == 0 ):
		print('bop')
		#rpm_curve = load("res://perfect_start_rpm_curve.tres")
		#car.apply_central_impulse(forward_vector * 20000)
		car.rpm_curve.set_point_value(0, car.rpm_curve.get_point_position(0).y + perfectStartBoost)
		car.rev_rpm = 0

func showPerfectStart(rev_rpm, current_gear) -> bool:
		if (rev_rpm > minPerfectValue and rev_rpm < maxPerfectValue) and current_gear == 0:
			return true
		else:
			return false

func removePerfectStartBoost(car) -> void:
	car.rpm_curve.set_point_value(0, car.rpm_curve.get_point_position(0).y - perfectStartBoost)
