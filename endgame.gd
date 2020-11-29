extends Node2D


func _ready():
	for debri in $debris.get_children():
		debri.apply_torque_impulse(rand_range(-1000,1000))
#		debri.angular_velocity = 1.0
