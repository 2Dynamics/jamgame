extends Bullet

func on_hit():
	globals.draw_heal(global_position, dmg_radius, dmg)
	queue_free()
