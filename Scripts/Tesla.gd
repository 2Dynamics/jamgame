extends Bullet
class_name Tesla

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func destroy():
	$Player.play("boom")
	$Particles2D2.process_material.set("direction", -velocity)
	
func clear():
	queue_free()
