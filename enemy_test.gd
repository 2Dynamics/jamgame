extends Node2D

var enemy_object = preload("res://Nodes/Enemy.tscn")

func _ready() -> void:
	randomize()
	globals.center = $Center
	globals.gravity_center = $Center.position
	globals.center_of_gravity = $Center.position

func _on_Timer_timeout():
	var new_enemy = enemy_object.instance()
	add_child(new_enemy)
	new_enemy.spawn()
