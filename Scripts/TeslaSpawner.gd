extends Node2D
class_name TeslaSpawner

var tesla_object := preload("res://Nodes/Tesla.tscn")
export var initial_speed := 200
export var spawn_distance:= 1000
func _ready():
	spawn()
	spawn()
	spawn()

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
	print ("new_tesla")
	print (new_tesla.position)
	print (new_tesla.velocity)
	
	
func _on_Timer_timeout():
	if $Timer.wait_time > 2.0:
		$Timer.wait_time -= 0.1
	spawn()
	
