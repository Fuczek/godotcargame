extends TextureRect

signal upgrade_chosen
var upgrade_to_load
#var modifiers_to_load : Array[Resource]
var icon
var title : String
var description : String

func _ready():
	var icon_texture = load(icon).get_image()
	icon_texture.resize(128, 128, 1)
	$ButtonIcon.texture_normal = ImageTexture.create_from_image(icon_texture)
	$Title.text = title
	$Description.text = description
	
func _on_pressed():
	var upgrade = upgrade_to_load
	emit_signal("upgrade_chosen", upgrade)
