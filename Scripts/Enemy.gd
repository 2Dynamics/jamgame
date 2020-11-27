extends Node2D
class_name Enemy

var bullet_object := preload("res://Nodes/Bullet.tscn")

export var life := 600.0

export var shoot_delay := 5.0

export var spawn_distance := 500.0
export var orbit_distance := 300.0

var velocity := Vector2.ZERO

var orbit_position := Vector2.ZERO

var is_in_orbit := false
var orbit_angle := 0.0 
var orbit_direction := 1 
var speed = 0.1

var is_alive = true

onready var sprite = $ufo

func _ready():
	randomize()
	$Timer.wait_time = shoot_delay
	spawn()

func _physics_process(delta):
#	if is_in_orbit:
	orbit_angle += orbit_direction * 0.01
	orbit_position = Vector2( cos(orbit_angle), sin(orbit_angle) ) * orbit_distance
		
#	else:
#		if position.distance_squared_to(orbit_position) < 1000:
#			is_in_orbit = true
	
	velocity += (orbit_position - position) * speed
	velocity *= 0.97
	position += velocity * delta
#	position = lerp(position, orbit_position, 0.01)
	
	sprite.rotation = (position.angle())
	damege()
		
		
func spawn():
	$explosion.rotation = rand_range(0,TAU) 
	orbit_distance += rand_range(-10,10)
	speed += rand_range(-0.01,0.01)
	orbit_angle = rand_range( 0, TAU )
	position = Vector2( cos(orbit_angle), sin(orbit_angle) ) * spawn_distance
	var angle_shift = rand_range(-0.1, 0.1)
	orbit_angle += angle_shift
	orbit_direction = sign( angle_shift )
	orbit_position = Vector2( cos(orbit_angle), sin(orbit_angle) ) * orbit_distance

func shoot():
	var new_bullet := bullet_object.instance() as Bullet
	get_parent().add_child( new_bullet )
	new_bullet.velocity = - position.normalized().rotated(-PI/2.0) * 100
	new_bullet.position = position
	new_bullet.dmg = 20000
	new_bullet.dmg_radius = 100
	

func damege():
	life -= 1
	if is_alive && life <= 0:
		is_alive = false
		$Particles2D.process_material.set("gravity", - position.normalized() * globals.gravity_scale)
		$Player.play("boom")
	
func _on_Timer_timeout():
	shoot()


func clear():
	queue_free()
