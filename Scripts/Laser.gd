extends Bullet

func _ready():
	velocity_damping = 0.0

func on_hit():
	globals.draw_explosion(global_position, dmg_radius, dmg)
	var expl = preload("res://Nodes/explosion.tscn").instance()
	get_parent().add_child(expl)
	expl.global_position = global_position
	queue_free()

func check_screen_borders():
	if global_position.x < globals.center.position.x - get_viewport_rect().size.x * 0.7 || global_position.x > globals.center.position.x + get_viewport_rect().size.x * 0.7:
		queue_free()

	if global_position.y < globals.center.position.y - get_viewport_rect().size.x * 0.7 || global_position.y > globals.center.position.y + get_viewport_rect().size.y * 0.7:
		queue_free()
