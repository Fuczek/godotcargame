extends PathFollow3D

var speed = 10

func _process(delta):
	set_progress(get_progress() - speed * delta)
