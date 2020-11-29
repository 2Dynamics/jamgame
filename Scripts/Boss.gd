extends Node2D
class_name Boss

var enemy_object := load("res://Nodes/Enemy.tscn")

export var life := 200000.0

export var bullet_speed:= 100.0

export var spawn_distance := 2200.0
export var orbit_distance := 800.0
export var orbit_variance := 10.0
export var orbit_speed := 2
export var start_timer := 1.0
var orbit_timer := 0.0
export var orbit_side := 0


var velocity := Vector2.ZERO

var orbit_position := Vector2.ZERO

var is_in_orbit := false
var orbit_angle := 0.0 
var speed = 0.05

export var ufos_to_spawn := 4
var spawn_side := 1

const eneny_id = 1999

var is_alive = true
var is_active = false
onready var sprite = $ufo

var friction := 0.99

func _ready():
	$ufo.visible = true
	$explosion.visible = false
	$Start_Timer.wait_time = start_timer
	$Start_Timer.start()
	spawn()

func _physics_process(delta):
	if !is_in_orbit:
		if position.distance_squared_to(orbit_position) < 1000:
			is_in_orbit = true
			$Timer.start()
			$AnimationPlayer.play("break")
		friction = 0.97
	else:
		orbit_timer += delta * 0.1
		orbit_angle = sin(orbit_timer) * 0.8 + orbit_side * PI
		orbit_position = Vector2( cos(orbit_angle), sin(orbit_angle) ) * orbit_distance
	
	
	if is_active:
		var distance_from_desired_orbit = orbit_position - position
		velocity += distance_from_desired_orbit.normalized() * min(distance_from_desired_orbit.length(), 100) * speed
		velocity *= friction
		position += velocity * delta
	
		sprite.rotation = (position.angle())

func spawn():
	$explosion.rotation = rand_range(0,TAU) 
	orbit_angle = orbit_side * PI
	
	position = Vector2( cos(orbit_angle), sin(orbit_angle) ) * spawn_distance
	orbit_position = Vector2( cos(orbit_angle), sin(orbit_angle) ) * orbit_distance

func spawn_ufo():
	$AudioStreamPlayer.play()
	spawn_side *= -1
	var new_enemy := enemy_object.instance() as Enemy

	get_parent().add_child( new_enemy )
	new_enemy.position = position
	new_enemy.orbit_angle = int(ufos_to_spawn)/10.0 * spawn_side + orbit_side * PI
	new_enemy.orbit_direction = sign( spawn_side )
	new_enemy.orbit_distance += 100 * orbit_side
#	new_enemy.orbit_position = Vector2( cos(orbit_angle), sin(orbit_angle) ) * new_enemy.orbit_distance

func damage(dmg:int):
	life -= dmg
	if is_alive && life <= 0:
		is_alive = false
		$Particles2D.process_material.set("gravity", - position.normalized() * globals.gravity_scale)
		$Player.play("boom")
		globals.add_score(1000)
		queue_free()
	
func _on_Timer_timeout():
	ufos_to_spawn -= 1
	spawn_ufo()
	if ufos_to_spawn <=0:
		ufos_to_spawn += 2
		$Timer.wait_time = 10

#func clear():
#	damege()



func _on_Start_Timer_timeout():
	is_active = true
	$Start_Timer.queue_free()
