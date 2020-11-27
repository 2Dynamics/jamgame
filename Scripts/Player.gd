extends Area2D

export var player: int

var center: Node2D
var velocity: Vector2

func _physics_process(delta: float) -> void:
	var move: Vector2
	move.x = int(Input.is_action_pressed(action("right"))) - int(Input.is_action_pressed(action("left")))
	move.y = int(Input.is_action_pressed(action("down"))) - int(Input.is_action_pressed(action("up")))
	
	var grav = global_position.direction_to(center.global_position)
	rotation = lerp_angle(rotation, grav.angle() - PI/2, 0.1)
	
	
	if global_position.distance_to(center.global_position) > 200: #tymczasowe
		velocity += grav * 1000 * delta
	else:
		velocity= Vector2(0,0)
	velocity += move * 400 * delta
	velocity *= 0.95
	
	position += velocity * delta

func action(action: String):
	return str("p", player, "_", action)
