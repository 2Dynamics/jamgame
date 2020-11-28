extends Area2D
class_name Player

export var player: int

var laser_scene = load("res://Nodes/Laser.tscn")
var rocket_scene = load("res://Nodes/Rocket.tscn")
var heal_rocket_scene = load("res://Nodes/HealRocket.tscn")
var fat_laser_scene = load("res://Nodes/FatLaser.tscn")
var fire_scene = load("res://Nodes/Fire.tscn")
var laser_rocket_scene = load("res://Nodes/LaserRocket.tscn")
var homing_rocket_scene = load("res://Nodes/HomingRocket.tscn")
var long_laser_scene = load("res://Nodes/LongLaser.tscn")

var center: Node2D
var velocity: Vector2
var prev_move: Vector2
var stun_time = 0
var reparable_time = 0
var weapon = -1
var wheel_points: Array
var previous_wheel_rotation := 0.0
var current_wheel_rotation := 0.0

export var color:Color

enum {LASER = -1, ROCKET, HEALING_ROCKET, FAT_LASER, FIRE, LASER_ROCKET, HOMING_ROCKET, LONG_LASER}

var front := Vector2.ZERO
var wheels := Vector2.ZERO

onready var aim = $aim
onready var sprite = $Sprite
var last_mouse_pos:Vector2

#onready var body_offset = $Sprite.position

func _ready() -> void:
	sprite.self_modulate = color
	for wheel in sprite.get_children():
		wheel_points.append(wheel.position)
		
func _physics_process(delta: float) -> void:
	var grav = global_position.direction_to(globals.center.global_position)
	var move: Vector2
	if stun_time <= 0:
		move.x = int(Input.is_action_pressed(action("right"))) - int(Input.is_action_pressed(action("left")))
		move.y = int(Input.is_action_pressed(action("down"))) - int(Input.is_action_pressed(action("up")))
	
	sprite.rotation = lerp_angle( sprite.rotation, grav.tangent().angle(), 0.1)
	sprite.rotation = lerp_angle( sprite.rotation, grav.tangent().angle(), 0.1)
	$CollisionShape2D.rotation = lerp_angle( $CollisionShape2D.rotation, grav.angle(), 0.1)
	
	velocity += grav * 1000 * delta
	velocity += move * 1200 * delta
	velocity *= 0.95

	process_suspension(grav)
	
	var raycast = globals.map.raycast(global_position - grav * 8, global_position + grav)
	if raycast and raycast.get("collision", true):
		velocity = velocity.slide(-grav)
		if raycast.pixel_number < 9:
			position = lerp(position, position - grav * (9 - raycast.pixel_number), 0.1)
	
#	update()
	var average_wheel :Vector2 = $Sprite/Wheel2.position - $Sprite/Wheel1.position
	average_wheel += $Sprite/Wheel3.position - $Sprite/Wheel2.position
	average_wheel /= 2.0
	
	
	var wierd_angle = grav.tangent().angle() + grav.tangent().angle_to(average_wheel)
	
	front = Vector2(cos(grav.tangent().angle()), sin(grav.tangent().angle()))
	wheels = Vector2(cos(grav.tangent().angle() - wierd_angle), sin(grav.tangent().angle() - wierd_angle))

	
	sprite.rotation = lerp_angle( sprite.rotation,  grav.tangent().angle() + wierd_angle, 0.5)
	
	position += velocity * delta
	
	process_pad_aim()
		
	process_mouse_aim()
		
	process_weapons()
	
	process_stun(delta)


	reparable_time -= delta
	if reparable_time <= 0:
		weapon = -1

	last_mouse_pos = get_global_mouse_position()
	
	
func process_suspension(grav):
	for i in 3:
		var wheel: Node2D = sprite.get_child(i)
		var high_point = wheel_points[i].rotated(rotation) - grav * 30
		var raycast = globals.map.raycast(global_position + high_point, global_position + high_point + grav * 20)
		
		if raycast and raycast.get("collision", true):
			wheel.position.y = wheel_points[i].y - 15 + raycast.pixel_number
	
func process_pad_aim():
	var deadzone = 0.5
	var controllerangle = Vector2.ZERO
	var xAxisRL = Input.get_joy_axis(player, JOY_AXIS_2)
	var yAxisUD = Input.get_joy_axis(player ,JOY_AXIS_3)

	if abs(xAxisRL) > deadzone || abs(yAxisUD) > deadzone:
		controllerangle = Vector2(xAxisRL, yAxisUD).angle()
		aim.global_rotation = controllerangle+PI*0.5

func process_mouse_aim():
	if player==0:
		var current_mouse_pos=get_global_mouse_position()
		if not last_mouse_pos.is_equal_approx(current_mouse_pos):
			aim.global_rotation = (current_mouse_pos-aim.global_position).angle()+PI*0.5

func process_weapons():
	if (stun_time <= 0) and Input.is_action_just_pressed(action("shoot")):
		var bullet = [laser_scene, rocket_scene, heal_rocket_scene,
			fat_laser_scene, fire_scene, laser_rocket_scene, homing_rocket_scene,
			long_laser_scene][weapon + 1]
#		bullet = homing_rocket_scene #debug
		bullet = shoot_bullet(bullet)
		match weapon:
			HOMING_ROCKET:
				bullet.velocity *= 2
				

func process_stun(delta):

	if stun_time > 0:
		stun_time -= delta
		if stun_time < 0:
			$AnimationPlayer.stop()
			sprite.modulate = color
			stun_time = 0

func shoot_bullet(b):
	var bullet = b.instance()
	bullet.shooter_id=player
	bullet.global_position=aim.global_position
	bullet.velocity=Vector2(0,-300).rotated(aim.global_rotation)
	get_parent().add_child(bullet)
	return bullet

func action(action: String):
	return str("p", player, "_", action)

func setStun():
	$hitsound.play()
	$AnimationPlayer.play("stun")
	stun_time = 1
	pass

func setReparableTime(w: int):
	reparable_time = 10
	weapon = w

#func _draw():
#
#	draw_line(Vector2.ZERO, front *100, Color.wheat,3)
#	draw_line(Vector2.ZERO, wheels *100, Color.green,3)
