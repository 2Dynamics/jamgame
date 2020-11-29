extends Bullet

var long = 15

func on_hit():
	globals.draw_explosion(global_position, dmg_radius, dmg)
	var expl = preload("res://Nodes/explosion.tscn").instance()
	get_parent().add_child(expl)
	expl.global_position = global_position
	
	long -= 1
	if long <= 0:
		queue_free()
