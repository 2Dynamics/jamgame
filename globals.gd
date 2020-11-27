extends Node2D

func _ready() -> void:
	var center = $Center
	for node in get_tree().get_nodes_in_group("falling"):
		node.center = center
