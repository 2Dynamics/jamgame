extends Area2D

export var player: int

var center: Node2D
var velocity: Vector2
onready var aim= $Sprite/aim

func _physics_process(delta: float) -> void:
	var move: Vector2
	move.x = int(Input.is_action_pressed(action("right"))) - int(Input.is_action_pressed(action("left")))
	move.y = int(Input.is_action_pressed(action("down"))) - int(Input.is_action_pressed(action("up")))
	
	var grav = global_position.direction_to(globals.center.global_position)
	rotation = lerp_angle(rotation, grav.angle() - PI/2, 0.1)
	
	velocity += grav * 1000 * delta
	velocity += move.rotated(grav.angle() - PI/2) * 1200 * delta
	velocity *= 0.95
	
	var raycast = globals.map.raycast(global_position - grav * 8, global_position + grav)
	if raycast:
		velocity = velocity.slide(-grav)
		if raycast.pixel_number < 9:
			position -= grav * (9 - raycast.pixel_number)
	
	position += velocity * delta
	
	if(Input.is_action_just_pressed("ui_accept")):
		globals.draw_explosion(get_global_mouse_position(),128,8555)
		
		
	var deadzone = 0.5
	var controllerangle = Vector2.ZERO
	var xAxisRL = Input.get_joy_axis(player, JOY_AXIS_2)
	var yAxisUD = Input.get_joy_axis(player ,JOY_AXIS_3)

	if abs(xAxisRL) > deadzone || abs(yAxisUD) > deadzone:

		controllerangle = Vector2(xAxisRL, yAxisUD).angle()
		aim.global_rotation = controllerangle+PI*0.5
	

func action(action: String):
	return str("p", player, "_", action)
