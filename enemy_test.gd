extends Node2D

var enemy_object = preload("res://Nodes/Enemy.tscn")

func _on_Timer_timeout():
	var new_enemy = enemy_object.instance()
	add_child(new_enemy)
	new_enemy.spawn()
