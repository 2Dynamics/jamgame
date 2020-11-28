extends Bullet

func on_hit():
	globals.draw_explosion(global_position, dmg_radius, dmg)
	var expl = preload("res://Nodes/explosion.tscn").instance()
	get_parent().add_child(expl)
	expl.global_position = global_position
	queue_free()

func _on_Timer_timeout() -> void:
	queue_free()
