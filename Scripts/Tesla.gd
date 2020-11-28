extends Bullet
class_name Tesla

onready var sprite = $Sprite

func _physics_process(delta):
	var grav = global_position.direction_to(globals.center.global_position)
	velocity += grav * globals.gravity_scale * delta
	velocity -= velocity * velocity_damping
	
	position += velocity * delta
	sprite.rotation = velocity.angle()

	if collideWithMap():
		on_hit()
		on_map_hit()
		
func on_map_hit():
	$Player.play("boom")
	$Particles2D.process_material.set("direction", -velocity)
	globals.draw_explosion(global_position, dmg_radius, dmg)
	velocity_damping *= 1.5
	
func on_hit():
	$Player.play("boom")

func clear():
	queue_free()
