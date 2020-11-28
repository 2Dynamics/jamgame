extends Node2D
class_name Bullet

export var dmg := 0
export var dmg_radius := 0
export var velocity_damping := 0.002
export var gravity_scale = 1.0

var shooter_id = -1
var velocity := Vector2.ZERO

func _physics_process(delta):
	var grav = global_position.direction_to(globals.center.global_position)
	velocity += grav * globals.gravity_scale * gravity_scale * delta
	velocity -= velocity * velocity_damping
	
	position += velocity * delta
	rotation = velocity.angle()

	if collideWithMap():
		on_map_hit()

func collideWithMap() -> bool:
	return globals.map.is_pixel_solid_v(global_position)

func on_hit(): pass
func on_map_hit():
	on_hit()

func _on_Bullet_area_entered(area):
	if area is Player:
		if shooter_id != area.player:
			area.setStun()
			on_hit()
	elif area.is_in_group("enemies"):
		if shooter_id != area.eneny_id:
			area.clear()
			on_hit()
		
