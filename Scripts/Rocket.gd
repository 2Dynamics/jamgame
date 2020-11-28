extends Bullet

func on_map_hit():
	globals.draw_explosion(global_position, dmg_radius, dmg)
	queue_free()
