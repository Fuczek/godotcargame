extends Button

@onready var reward_icon = $reward_icon

signal map_chosen
var map_to_load : PackedScene
var modifiers_to_load : Array[Resource]
var reward_icon_to_load : String
var rewards : Resource

func _ready():
	var icon_texture = load(reward_icon_to_load).get_image()
	#icon_texture.resize(128, 128, 1)
	reward_icon.texture = ImageTexture.create_from_image(icon_texture)

func _on_pressed():
	var map = map_to_load.instantiate()
	emit_signal("map_chosen", map, modifiers_to_load, rewards)
	
