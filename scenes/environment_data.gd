extends WorldEnvironment

@onready var skies = {
	"early": preload("res://environment/sky_early.tres"),
	"late": preload("res://environment/sky_late.tres"),
	"night": preload("res://environment/sky_night.tres"),
}

@onready var sunlights = {
	"early": $sunlight_early,
	"late": $sunlight_late,
	"night": $sunlight_night
}

# Called when the node enters the scene tree for the first time.
func _ready():
	change_environment(9)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func change_environment(player_hour):
	for each in get_tree().get_nodes_in_group('sunlight'):
		each.hide()
	match(player_hour):
		9:
			environment.set_sky(skies.early)
			sunlights.early.show()
		12:
			environment.set_sky(skies.late)
			sunlights.late.show()
		15:
			environment.set_sky(skies.night)
			sunlights.night.show()
		_:
			environment.set_sky(skies.night)
			sunlights.night.show()
