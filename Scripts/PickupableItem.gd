extends Node2D

var weapon: int

func _ready() -> void:
	weapon = randi() % $Icons.get_child_count()
	$Icons.get_child(weapon).show()

func _on_PickupableItem_area_entered(area):
	if area is Player:
		area.setReparableTime(weapon)
		queue_free()
