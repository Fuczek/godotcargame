extends Button

signal restart_game

func _ready():
	restart_game.connect(get_tree().get_first_node_in_group("hud_group").restart_game)

func _on_pressed():
	emit_signal("restart_game")
