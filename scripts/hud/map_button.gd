extends Button

signal map_chosen
var map_to_load : PackedScene

func _on_pressed():
	var map = map_to_load.instantiate()
	emit_signal("map_chosen", map)
	
