extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_core_area_entered(area):
	if area is Bullet:
		($"../endgame_timer" as Timer).start()
#		($"../spawn_timer" as Timer).start()
#		get_parent().start_endgame()
	pass # Replace with function body.
