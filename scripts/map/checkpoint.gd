extends Area3D

@onready var checkpoint_ball_mesh = $checkpoint_ball
@onready var find_floor_raycast = $find_floor_raycast
signal hit

var material
var new_material = StandardMaterial3D.new()

func _ready():
	material = checkpoint_ball_mesh.get_active_material(0)
	
func _on_body_entered(body):
	if (body.is_in_group("driver") and !body.finished):
		if ((str(body.next_checkpoint_id)) == self.name):
			hit.connect(body.collect_checkpoint)
			emit_signal("hit", body.name, self.global_position)
			new_material.albedo_color = Color.from_hsv(1.4, 0.65, 1.0, 0)
			new_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			self.checkpoint_ball_mesh.set_surface_override_material(0, new_material)
			await get_tree().create_timer(1.0).timeout
			self.checkpoint_ball_mesh.set_surface_override_material(0, material)
		#else:
			#eventual wrong checkpoint signal, maybe with automatic reset

func _process(delta):
	if find_floor_raycast.is_colliding():
		#print(find_floor_raycast.get_collision_point())
		self.global_position = find_floor_raycast.get_collision_point()
		find_floor_raycast.set_enabled(false)
