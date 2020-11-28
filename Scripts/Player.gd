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
var collider_points: Array
var collider_directions: Array
var previous_wheel_rotation := 0.0
var current_wheel_rotation := 0.0

export var color:Color

enum {LASER = -1, ROCKET, HEALING_ROCKET, FAT_LASER, FIRE, LASER_ROCKET, HOMING_ROCKET, LONG_LASER}

var front := Vector2.ZERO
var up := Vector2.ZERO
var wheels := Vector2.ZERO

onready var aim = $aim
onready var suspension = $Suspension
var last_mouse_pos:Vector2

var is_on_ground = false

func _ready() -> void:
	$body.self_modulate = color
	for wheel in suspension.get_children():
		wheel_points.append(wheel.position)
	
	for collider in $colliders.get_children():
		collider_points.append(collider.position)
		collider_directions.append(collider.position.normalized())
		
func _physics_process(delta: float) -> void:
	var grav = global_position.direction_to(globals.center.global_position)
	var move: Vector2
	if stun_time <= 0:
		move.x = int(Input.is_action_pressed(action("right"))) - int(Input.is_action_pressed(action("left")))
		move.y = int(Input.is_action_pressed(action("down"))) - int(Input.is_action_pressed(action("up")))
	
	
	var raycast = globals.map.raycast(global_position - grav * 8, global_position + grav)
	if raycast and raycast.get("collision", true):
		velocity = velocity.slide(-grav)
		if raycast.pixel_number < 9:
			position = lerp(position, position - grav * (9 - raycast.pixel_number), 0.1)
	
	var average_wheel :Vector2 = ($Suspension/Wheel2.position - $Suspension/Wheel1.position).normalized()
	average_wheel += ($Suspension/Wheel3.position - $Suspension/Wheel2.position).normalized()
	average_wheel /= 2.0
	
	wheels = average_wheel.rotated(rotation)
	front = Vector2.RIGHT.rotated(rotation)
	
	up = Vector2.UP.rotated(rotation)
	
	velocity += move * 600 * delta

	process_suspension( delta, grav )
	process_collisions( delta )
	
	if is_on_ground:
		velocity += grav * globals.gravity_scale * 1 * delta
	else:
		velocity += grav * globals.gravity_scale * 5 * delta
		
#	update()
	velocity -= velocity * 0.06
	position += velocity * delta
	
	process_pad_aim()
	
	process_mouse_aim()
	
	process_weapons()
	
	process_stun(delta)

	reparable_time -= delta
	if reparable_time <= 0:
		weapon = -1

	last_mouse_pos = get_global_mouse_position()
	
	
func process_suspension(delta, grav):
	is_on_ground = false
	var average_ray_length := 0.0
	var collisions_count := 0
	var force_direction := Vector2.ZERO
	var torque = 0.0
	var wheel_force = Vector2.ZERO
	var force = 0.0
	for i in 3:
		var wheel: Node2D = suspension.get_child(i)
		var high_point = wheel_points[i].rotated(rotation) + up * 30
		var raycast = globals.map.raycast(global_position + high_point, global_position + high_point - up * 20)
		
		
		if raycast and raycast.get("collision", true):
			force = 13.0 / max( 1.0, raycast.pixel_number )
			wheel.position.y = wheel_points[i].y - 10 + raycast.pixel_number
			average_ray_length += raycast.pixel_number
			collisions_count += 1
			torque -= (up).cross(wheel.position.rotated(rotation) )
			wheel_force += ((suspension.position - wheel.position).rotated(rotation)).normalized() * force
#			wheel_force += (wheel.position-suspension.position).normalized() * force
			
			is_on_ground = true
		else:
			wheel.position.y = wheel_points[i].y + 7
			
	if is_on_ground:
		velocity += wheel_force
		rotation = lerp_angle(rotation, rotation + torque * 0.01, 0.1)
	else:
		rotation = lerp_angle(rotation, grav.angle()-PI/2.0, 0.1)
		
	if collisions_count:
		average_ray_length /= collisions_count

func process_collisions( delta ):
	var force := 0.0
	var colider_position := Vector2.ZERO
	var total_force = Vector2.ZERO
	for i in 4:
		colider_position = global_position + collider_points[i].rotated(rotation)
		var raycast = globals.map.raycast(colider_position, colider_position + collider_directions[i].rotated(rotation) * 5)
		if raycast and raycast.get("collision", true):
			print (raycast.pixel_number)
			force = 5.0 / max( 1.0, raycast.pixel_number )
			total_force -= collider_directions[i].rotated(rotation) * force
	velocity += total_force

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
			$body.modulate = color
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
	$AnimationPlayer.play("stun")
	stun_time = 1
	pass

func setReparableTime(w: int):
	reparable_time = 10
	weapon = w
