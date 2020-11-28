extends Bullet
class_name Tesla

onready var sprite = $Sprite

func _physics_process(delta):
#	$Sprite.rotation = -rotation
	$Particles2D.rotation = - rotation
	$explosion.rotation = - rotation
	
		
func on_map_hit():
	$Player.play("boom")
	$Particles2D.process_material.set("direction", -velocity)
	globals.draw_explosion(global_position, dmg_radius, dmg)
	velocity_damping *= 1.5
#	dmg_radius *= 1.5
	dmg *= 1.1
	
func on_hit():
	$Player.play("boom")

func clear():
	queue_free()
