extends Node2D


func _ready():
	for debri in $debris.get_children():
		debri.angular_velocity = rand_range(-0.1, 0.1)
		debri.linear_velocity = debri.position.normalized()*3
	for wheel in $wheels.get_children():
		wheel.angular_velocity = rand_range(-0.1, 0.1)
		wheel.linear_velocity = wheel.position.normalized()*3
		
	$Core.angular_velocity = 0.05
	$Core2.angular_velocity = -0.02
	$Core3.angular_velocity = 0.015
	$Core4.angular_velocity = 0.03
	$Core5.angular_velocity = -0.025
	$Core6.angular_velocity = -0.035
	$Core7.angular_velocity = 0.045
	$Core2.linear_velocity = $Core2.position.normalized() * 1.00
	$Core3.linear_velocity = $Core3.position.normalized() * 1.00
	$Core4.linear_velocity = $Core4.position.normalized() * 2.50
	$Core5.linear_velocity = $Core5.position.normalized() * 3.00
	$Core6.linear_velocity = $Core6.position.normalized() * 2.00
	$Core7.linear_velocity = $Core6.position.normalized() * 4.00
	
	$Tesla.angular_velocity = rand_range(-0.1, 0.1)
	$Tesla.linear_velocity = $Tesla.position.normalized() * 3.00
	
	$Rover1.angular_velocity = rand_range(-0.1, 0.1)
	$Rover2.angular_velocity = rand_range(-0.1, 0.1)
	$Rover3.angular_velocity = rand_range(-0.1, 0.1)
	$Rover4.angular_velocity = rand_range(-0.1, 0.1)

func setup_wheels():
	for wheel in $wheels.get_children():
		wheel.global_position = get_node("Rover"+str(randi()%4+1)).global_position + Vector2(rand_range(-10,10),rand_range(-10,10))
