extends Bullet
class_name Tesla

onready var sprite = $Sprite

func _ready():
	shooter_id = 999
	$explosion.visible = false
	$Sprite.visible = true
	
#func _physics_process(delta):
#	$Particles2D.rotation = - rotation
#	$explosion.rotation = - rotation

func on_map_hit():
	
#	$Particles2D.process_material.set("gravity", velocity*100)
	globals.draw_explosion(global_position, dmg_radius, dmg)
	velocity_damping *= 1.3
#	dmg_radius *= 1.5
	dmg *= 1.1
	if !$AudioStreamPlayer2D2.playing:
		$Player.play("boom")
		$Particles2D.rotation = $Sprite.rotation
		var new_grav = Vector3(position.x,position.y,0)
		$Particles2D.process_material.set("gravity", -new_grav.normalized()*100)
		$AudioStreamPlayer2D2.play()
	
func on_hit():
	globals.draw_explosion(global_position, dmg_radius, dmg)
	queue_free()

func clear():
	queue_free()

func _on_AudioStreamPlayer2D2_finished():
	queue_free()
