extends Button

signal map_chosen
var map_to_load : PackedScene
var modifiers_to_load : Array[Resource]

func _on_pressed():
	var map = map_to_load.instantiate()
	emit_signal("map_chosen", map, modifiers_to_load)
