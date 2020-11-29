extends Node2D

onready var score = $CanvasLayer/Label

var pickupableitem_scene := load("res://Nodes/PickupableItem.tscn")
var enemy_scene := load("res://Nodes/Enemy.tscn")
var boss_scene := load("res://Nodes/Boss.tscn")
var endgame_scene := preload("res://endgame.tscn")

var spawn_pickupable_time = 5
var spawn_pickupable_timer = 0
var min_spawn_pickupableitem_radius = 120
var max_spawn_pickupableitem_radius = 400

var spawn_enemy_time = 20
var spawn_enemy_timer = 0
var boss_count := 0



func _ready() -> void:
	randomize()
	globals.center = $Center
	globals.map = $DynamicGridMap
	globals.connect("score_changed", self, "update_score")
	
	var f = File.new()
	if f.file_exists("user://score"):
		f.open("user://score", f.READ)
		$CanvasLayer/Label2.text = "HIGHSCORE " + f.get_line()
	else:
		$CanvasLayer/Label2.hide()

func update_score():
	score.text = str("SCORE ", globals.score)

func _process(delta):
	spawn_pickupable_timer += delta
	if spawn_pickupable_timer >= spawn_pickupable_time:
		spawn_pickupable_timer = 0
		var spawn_radius = rand_range(min_spawn_pickupableitem_radius,max_spawn_pickupableitem_radius)
		var spawn_angle = rand_range( 0, TAU )
		var pickupable_item = pickupableitem_scene.instance()
		$Center.add_child(pickupable_item)
		pickupable_item.global_position = globals.center.global_position + Vector2(spawn_radius, 0).rotated(spawn_angle)

	if spawn_enemy_timer < spawn_enemy_time:
		spawn_enemy_timer += delta
	else:
		spawn_enemy_timer = 0
		var enemy = enemy_scene.instance()
		$Center.add_child(enemy)
		
	if !$Center.has_node("Boss1"):
		var boss = boss_scene.instance()
		boss_count += 1
		boss.name = "Boss1"
		boss.start_timer = 10.0
		boss.orbit_side = 1
		boss.ufos_to_spawn += boss_count
		$Center.add_child(boss)
#		boss.get_node("Start_Timer").wait_time = 10.0
	if !$Center.has_node("Boss2"):
		boss_count += 1
		var boss = boss_scene.instance()
		boss.name = "Boss2"
		boss.start_timer = 10.0
		boss.ufos_to_spawn += boss_count
		$Center.add_child(boss)
#		boss.get_node("Start_Timer").wait_time = 10.0

var endgame: int

func _on_endgame_timer_timeout():
	if endgame< 60:
		var explo = preload("res://Nodes/big_explosion.tscn").instance()
		explo.rotation=rand_range(0,2*PI)
		explo.scale*=rand_range(0.5,1.5)
		explo.position= Vector2(rand_range(-300,300),rand_range(-300,300))
		$Center.add_child(explo)
	if endgame == 59:
		$endgame.play("end")
	if endgame == 60:
		start_endgame()
	if endgame == 0:
		$endsound.play()
		var f := File.new()
		var s = 0
		if f.file_exists("user://score"):
			f.open("user://score", f.READ)
			s = int(f.get_line())
			f.close()
		f.open("user://score", f.WRITE)
		f.store_line(str(max(s, globals.score)))
		globals.disconnect("score_changed", self, "update_score")
	
	endgame += 1
	if endgame >= 600:
		get_tree().change_scene("res://Title.tscn")

func start_endgame():
	var explo = endgame_scene.instance()
	$core.queue_free()
	add_child(explo)
	explo.position = $Center.position
	explo.get_node("Rover1").position = $Player.position- $Center.position
	explo.get_node("Rover2").position = $Player2.position- $Center.position
	explo.get_node("Rover3").position = $Player3.position- $Center.position
	explo.get_node("Rover4").position = $Player4.position- $Center.position
	explo.setup_wheels()
	
	$Center.queue_free()
	
	$Player.queue_free()
	$Player2.queue_free()
	$Player3.queue_free()
	$Player4.queue_free()
	$DynamicGridMap.visible = false
	set_process(false)


func _on_spawn_timer_timeout():
	start_endgame()
