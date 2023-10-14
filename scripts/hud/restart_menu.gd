extends ColorRect

@onready var restart_button = $restart_button
@onready var reset_button = $reset_button

var player_restarts : int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	player_restarts = get_tree().get_first_node_in_group("player_data").player_restarts_remaining
	restart_button.text = "Restart the race ( " + str(player_restarts) + " remaining)"
	
	if player_restarts == 0:
		restart_button.set_disabled(true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_reset_button_pressed():
	get_tree().get_first_node_in_group("player_data").clear_data()
	get_tree().get_first_node_in_group("map_list").randomize_next_map(true)
	self.queue_free()

func _on_restart_button_pressed():
	var player = get_tree().get_first_node_in_group("player")
	var uses_remaining = player.restarts_remaining
	uses_remaining = player.restartAbility.restart(uses_remaining)
	get_tree().get_first_node_in_group("player_data").player_restarts_remaining = uses_remaining
	get_tree().get_first_node_in_group("map_list").randomize_next_map(true)
	self.queue_free()
