extends Bullet

func on_hit():
	globals.draw_explosion(global_position, dmg_radius, dmg)
	var expl = preload("res://Nodes/explosion.tscn").instance()
	expl.scale *= 2
	get_parent().add_child(expl)
	expl.global_position = global_position
	queue_free()

func _on_Timer_timeout() -> void:
	var laser = load("res://Nodes/Laser.tscn").instance()
	laser.scale *= 0.5
	laser.dmg *= 0.5
	laser.dmg_radius *= 0.5
	
	laser.position = position
	var dir = velocity.rotated(PI/2)
	if global_position.direction_to(globals.center.global_position).dot(dir.normalized()) > 0:
		dir *= -1
	laser.velocity = dir
	get_parent().add_child(laser)
