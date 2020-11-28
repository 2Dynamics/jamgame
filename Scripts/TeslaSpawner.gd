extends Node2D
class_name TeslaSpawner

var tesla_object := preload("res://Nodes/Tesla.tscn")
export var initial_speed := 200
export var spawn_distance:= 1000
export var spawn_timer := 10.0
export var spawn_timer_minimal := 2.0
export var spawn_speed_up := 0.2
func _ready():
	$Timer.wait_time = spawn_timer
	
func spawn():
	var new_tesla := tesla_object.instance() as Bullet
	get_parent().add_child( new_tesla )
	var angle = rand_range( 0, TAU )
	var spawn_point = Vector2( cos(angle), sin(angle) ) * spawn_distance
	var direction_rand = randi()%2
	var direction = spawn_point.tangent() * (direction_rand * 2 - 1)
	
	new_tesla.get_node("Sprite").flip_v = !bool(direction_rand)
	
	new_tesla.velocity = -direction.normalized() * initial_speed
	new_tesla.position = spawn_point
	new_tesla.dmg = 1000
	new_tesla.dmg_radius = 50
	new_tesla.velocity_damping += 0.002

	
func _on_Timer_timeout():
	if $Timer.wait_time > spawn_timer_minimal:
		$Timer.wait_time -= spawn_speed_up
	spawn()
	
