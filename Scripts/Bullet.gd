extends Node2D
class_name Bullet

var explosion_scene=preload("res://Nodes/explosion.tscn")

var shooter_id=-1
var velocity := Vector2.ZERO
var dmg := 0
var dmg_radius := 0

func _physics_process(delta):
	var grav = global_position.direction_to(globals.center.global_position)
	velocity += grav * 250 * delta
	position += velocity * delta
	rotation = velocity.angle()

	if collideWithMap():
		globals.draw_explosion(global_position, dmg_radius, dmg)
		var expl=explosion_scene.instance()
		get_parent().add_child(expl)
		expl.global_position=global_position

		queue_free()
		# todo

func collideWithMap():
	return globals.map.is_pixel_solid_v(global_position)
	pass


func _on_Bullet_area_entered(area):
	if area is Player:
		if shooter_id!=area.player:
			area.setStun()
			globals.draw_explosion(global_position, dmg_radius, dmg)
			var expl=explosion_scene.instance()
			get_parent().add_child(expl)
			expl.global_position=global_position

			
			queue_free()
	pass # Replace with function body.
