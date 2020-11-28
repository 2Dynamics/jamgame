extends Node2D
class_name Bullet

export var dmg := 0
export var dmg_radius := 0

var shooter_id = -1
var velocity := Vector2.ZERO

func _physics_process(delta):
	var grav = global_position.direction_to(globals.center.global_position)
	velocity += grav * 250 * delta
	position += velocity * delta
	rotation = velocity.angle()

	if collideWithMap():
		on_map_hit()

func collideWithMap() -> bool:
	return globals.map.is_pixel_solid_v(global_position)

func on_map_hit(): pass

func _on_Bullet_area_entered(area):
	if area is Player:
		if shooter_id != area.player:
			area.setStun()
			globals.draw_explosion(global_position, dmg_radius, dmg)
			var expl=explosion_scene.instance()
			get_parent().add_child(expl)
			expl.global_position=global_position

			
			queue_free()
