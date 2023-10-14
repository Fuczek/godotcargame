extends Node3D

@onready var cam = $SpringArm3D/Camera3D
var new_rot
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#if Input.is_action_pressed("camera_left"):
		
		#var new_cam_rot = lerp(self.rotation_degrees, Vector3(self.rotation_degrees.x, get_parent().rotation_degrees.y, self.rotation_degrees.z), 0.5) 
		#self.rotation_degrees = new_cam_rot
		
		#new_rot = lerp(int(self.rotation_degrees.y), -90, 0.1)
		#print(new_rot)
		#new_rot = clamp(self.rotation_degrees.y, -90, 0)
		#print('huj')
		#self.rotation_degrees.y = new_rot
