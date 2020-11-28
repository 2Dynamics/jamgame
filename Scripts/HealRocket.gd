extends Bullet


func on_hit():
	var expl = preload("res://Nodes/explosion.tscn").instance()
	expl.scale *= 2
	get_parent().add_child(expl)
	expl.global_position = global_position
	queue_free()

func on_map_hit():
	globals.draw_heal(global_position, dmg_radius, dmg)
