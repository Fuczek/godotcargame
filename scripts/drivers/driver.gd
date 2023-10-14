@tool
extends Node

@export var driver_name : String
@export var level : int = 1
@export var vehicle_model : Mesh
@export var modifiers_array : Array[Resource]

var modifiers_node : Node
var modifier_index : int
var is_ready : bool = false
var amount_of_modifiers : int

signal changed_modifier

func _ready():
	#print(self.get_parent())
	if self.get_parent():
		get_parent().get_node("name").text = driver_name
		get_parent().get_node("model").mesh = vehicle_model
		modifiers_node = get_parent().get_node("modifiers")
		amount_of_modifiers = modifiers_node.get_child_count()
		update_modifiers()
		is_ready = true

var old_modifier_array : int = 0

func _process(delta):
	if is_ready:
		if modifiers_array.size() != old_modifier_array:
			update_modifiers()
	#var new_amount_of_modifiers = modifiers_node.get_child_count()
	#print(new_amount_of_modifiers, " ", amount_of_modifiers)
	#if new_amount_of_modifiers != amount_of_modifiers:
		#update_modifiers()

func update_modifiers():
	old_modifier_array = modifiers_array.size()
	for already_existing_sprites in modifiers_node.get_children():
		already_existing_sprites.queue_free()

	modifier_index = 0
	for modifier in modifiers_array:
		var icon : Sprite3D = Sprite3D.new()
		var mod = modifier.new()
		var icon_texture = load(mod.icon).get_image()
		icon.set_billboard_mode(1)
		icon_texture.resize(128, 128, 1)
		icon.position.x += 1.5 * modifier_index
		icon.position.y = 3
		icon.texture = ImageTexture.create_from_image(icon_texture)
		modifiers_node.add_child(icon)
		icon.set_owner(get_tree().edited_scene_root)
		modifier_index += 1

	
