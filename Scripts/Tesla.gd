extends Bullet
class_name Tesla

onready var sprite = $Sprite

func _physics_process(delta):
	$Particles2D.rotation = - rotation
	$explosion.rotation = - rotation

func on_map_hit():
	$Player.play("boom")
	$Particles2D.process_material.set("direction", -velocity)
	globals.draw_explosion(global_position, dmg_radius, dmg)
	velocity_damping *= 1.3
#	dmg_radius *= 1.5
	dmg *= 1.1
	if !$AudioStreamPlayer2D2.playing:
		$AudioStreamPlayer2D2.play()
	
func on_hit():
	globals.draw_explosion(global_position, dmg_radius, dmg)
	queue_free()

func clear():
	queue_free()



func _on_AudioStreamPlayer2D2_finished():
	queue_free()
