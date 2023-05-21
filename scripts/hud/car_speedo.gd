extends Label

func ready():
	self.update_speedo.connect(update_speedo)
	
func update_speedo(speedo):
	print('huj')
