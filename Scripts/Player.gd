extends Area2D
var bullet_scene= preload("res://Nodes/Bullet.tscn")
export var player: int

var center: Node2D
var velocity: Vector2
var prev_move: Vector2
var wheel_points: Array

onready var aim = $aim
onready var sprite = $Sprite

func _ready() -> void:
	for wheel in sprite.get_children():
		wheel_points.append(wheel.position)
var last_mouse_pos:Vector2
onready var aim= $Sprite/aim

func _physics_process(delta: float) -> void:
	var grav = global_position.direction_to(globals.center.global_position)
	var move: Vector2
	move.x = int(Input.is_action_pressed(action("right"))) - int(Input.is_action_pressed(action("left")))
	move.y = int(Input.is_action_pressed(action("down"))) - int(Input.is_action_pressed(action("up")))
	
	rotation = lerp_angle(rotation, grav.angle() - PI/2, 0.1)
	
	velocity += grav * 1000 * delta
	velocity += move * 1200 * delta
	velocity *= 0.95
	
	for i in 3:
		var wheel: Node2D = sprite.get_child(i)
		var high_point = wheel_points[i].rotated(rotation) - grav * 30
		var raycast = globals.map.raycast(global_position + high_point, global_position + high_point + grav * 60)
		
		if raycast and raycast.get("collision", true):
			wheel.position.y = wheel_points[i].y - 15 + raycast.pixel_number
	
	var raycast = globals.map.raycast(global_position - grav * 8, global_position + grav)
	if raycast and raycast.get("collision", true):
		velocity = velocity.slide(-grav)
		if raycast.pixel_number < 9:
			position -= grav * (9 - raycast.pixel_number)
	
	position += velocity * delta
	
	
		
	var deadzone = 0.5
	var controllerangle = Vector2.ZERO
	var xAxisRL = Input.get_joy_axis(player, JOY_AXIS_2)
	var yAxisUD = Input.get_joy_axis(player ,JOY_AXIS_3)

	if abs(xAxisRL) > deadzone || abs(yAxisUD) > deadzone:

		controllerangle = Vector2(xAxisRL, yAxisUD).angle()
		aim.global_rotation = controllerangle+PI*0.5
	
	if player==0:
		var current_mouse_pos=get_global_mouse_position()
		if last_mouse_pos!=current_mouse_pos:
			aim.global_rotation = (current_mouse_pos-aim.global_position).angle()+PI*0.5
		
	if Input.is_action_just_pressed(action("shoot")):
		var bullet=bullet_scene.instance()
		bullet.global_position=aim.global_position
		bullet.velocity=Vector2(0,-300).rotated(aim.global_rotation)
		bullet.dmg=10000
		bullet.dmg_radius=60
		
		get_parent().add_child(bullet)
		
	last_mouse_pos=get_global_mouse_position()
	

func action(action: String):
	return str("p", player, "_", action)
