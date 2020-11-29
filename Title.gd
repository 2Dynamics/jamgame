extends TextureRect

func _ready() -> void:
	var f = File.new()
	if f.file_exists("user://score"):
		f.open("user://score", f.READ)
		$Label2.text = "HIGHSCORE " + f.get_line()
	else:
		$Label2.hide()

func _input(event: InputEvent) -> void:
	if event.is_pressed() && !$AnimationPlayer.is_playing():
		$AnimationPlayer.play("stop_music")
		$Label.text = "LOADING"
		

func start_game():
	get_tree().change_scene("res://PlayerTest.tscn")

