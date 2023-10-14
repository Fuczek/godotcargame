extends WorldEnvironment

@onready var skies = {
	"early": preload("res://environment/sky_early.tres"),
	"midday": preload("res://environment/sky_early.tres"),
	"late": preload("res://environment/sky_late.tres"),
	"night": preload("res://environment/sky_night.tres"),
}

@onready var sunlights = {
	"early": $sunlight_early,
	"midday": $sunlight_midday,
	"late": $sunlight_late,
	"night": $sunlight_night,
}

# Called when the node enters the scene tree for the first time.
func _ready():
	change_environment("8:00 AM")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func change_environment(player_hour):
	for each in get_tree().get_nodes_in_group('sunlight'):
		each.hide()
	match(player_hour):
		"8:00 AM":
			environment.set_sky(skies.early)
			sunlights.early.show()
		"12:00 AM":
			environment.set_sky(skies.midday)
			sunlights.midday.show()
		"4:00 PM":
			environment.set_sky(skies.late)
			sunlights.late.show()
		"8:00 PM":
			environment.set_sky(skies.late)
			sunlights.late.show()
		"12:00 PM":
			environment.set_sky(skies.night)
			sunlights.night.show()
		_:
			environment.set_sky(skies.night)
			sunlights.night.show()
