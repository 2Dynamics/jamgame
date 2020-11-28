extends Bullet

var target

func _ready() -> void:
	var dist = INF
	
	for enemy in get_tree().get_nodes_in_group("enemies"):
		var d = global_position.distance_squared_to(enemy.global_position)
		if d < dist:
			dist = d
			target = enemy

func _physics_process(delta: float) -> void:
	if target:
		if not is_instance_valid(target):
			target = null
			return
		
		velocity = Vector2.RIGHT.rotated(lerp_angle(velocity.angle(), target.global_position.angle_to_point(global_position), 0.1)) * velocity.length()

func on_hit():
	globals.draw_explosion(global_position, dmg_radius, dmg)
	var expl = preload("res://Nodes/explosion.tscn").instance()
	expl.scale *= 2
	get_parent().add_child(expl)
	expl.global_position = global_position
	queue_free()

