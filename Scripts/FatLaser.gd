extends Bullet

const DANGLE = PI / 16

func on_hit():
	globals.draw_explosion(global_position, dmg_radius, dmg)
	var expl = preload("res://Nodes/explosion.tscn").instance()
	get_parent().add_child(expl)
	expl.global_position = global_position
	queue_free()

func _on_Timer_timeout() -> void:
	for i in 3:
		var laser = load("res://Nodes/Laser.tscn").instance()
		laser.position = position
		laser.velocity = velocity.rotated(-DANGLE + i * DANGLE)
		get_parent().add_child(laser)
	queue_free()
