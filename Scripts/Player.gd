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

export var color:Color

enum {LASER = -1, ROCKET, HEALING_ROCKET, FAT_LASER, FIRE, LASER_ROCKET, HOMING_ROCKET, LONG_LASER}

onready var aim = $aim
onready var sprite = $Sprite

func _ready() -> void:
	sprite.modulate=color
	for wheel in sprite.get_children():
		wheel_points.append(wheel.position)
var last_mouse_pos:Vector2


func _physics_process(delta: float) -> void:
	var grav = global_position.direction_to(globals.center.global_position)
	var move: Vector2
	if stun_time <= 0:
		move.x = int(Input.is_action_pressed(action("right"))) - int(Input.is_action_pressed(action("left")))
		move.y = int(Input.is_action_pressed(action("down"))) - int(Input.is_action_pressed(action("up")))
	
	rotation = lerp_angle(rotation, grav.angle() - PI/2, 0.1)
	
	velocity += grav * 1000 * delta
	velocity += move * 1200 * delta
	velocity *= 0.95
	
	for i in 3:
		var wheel: Node2D = sprite.get_child(i)
		var high_point = wheel_points[i].rotated(rotation) - grav * 30
		var raycast = globals.map.raycast(global_position + high_point, global_position + high_point + grav * 20)
		
		if raycast and raycast.get("collision", true):
			wheel.position.y = wheel_points[i].y - 15 + raycast.pixel_number
	
	var raycast = globals.map.raycast(global_position - grav * 8, global_position + grav)
	if raycast and raycast.get("collision", true):
		velocity = velocity.slide(-grav)
		if raycast.pixel_number < 9:
			position = lerp(position, position - grav * (9 - raycast.pixel_number), 0.1)
	
	position += velocity * delta
	
	var deadzone = 0.5
	var controllerangle = Vector2.ZERO
	var xAxisRL = Input.get_joy_axis(player, JOY_AXIS_2)
	var yAxisUD = Input.get_joy_axis(player ,JOY_AXIS_3)

	if abs(xAxisRL) > deadzone || abs(yAxisUD) > deadzone:
		controllerangle = Vector2(xAxisRL, yAxisUD).angle()
		aim.global_rotation = controllerangle+PI*0.5

	
	if player == 0:
		var current_mouse_pos = get_global_mouse_position()
		if not last_mouse_pos.is_equal_approx(current_mouse_pos):
			aim.global_rotation = (current_mouse_pos-aim.global_position).angle()+PI*0.5
		
	if (stun_time <= 0) and Input.is_action_just_pressed(action("shoot")):
		var bullet = [laser_scene, rocket_scene, heal_rocket_scene,
			fat_laser_scene, fire_scene, laser_rocket_scene, homing_rocket_scene,
			long_laser_scene][weapon + 1]
#		bullet = homing_rocket_scene #debug
		bullet = shoot_bullet(bullet)
		match weapon:
			HOMING_ROCKET:
				bullet.velocity *= 2

	if stun_time > 0:
		stun_time -= delta
		if stun_time < 0:
			$AnimationPlayer.stop()
			sprite.modulate=color
			stun_time = 0

	reparable_time -= delta
	if reparable_time <= 0:
		weapon = -1

	last_mouse_pos=get_global_mouse_position()

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
	$AnimationPlayer.play("stun")
	stun_time = 4
	pass

func setReparableTime(w: int):
	reparable_time = 10
	weapon = w
