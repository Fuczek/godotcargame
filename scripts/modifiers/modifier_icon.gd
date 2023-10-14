extends TextureRect

@onready var modifier_level = $modifier_level
@onready var modifier_uses = $modifier_uses
var level : int
var uses : int
var title : String

func _ready():
	if title:
		name = title
	if level:
		modifier_level.text = str(level)
	if uses:
		modifier_uses.text = "X" + str(uses)

func update_values(uses):
	modifier_uses.text = "X" + str(uses)
	if uses == 0:
		queue_free()
