extends Node2D

onready var score = $CanvasLayer/Label

var pickupableitem_scene := load("res://Nodes/PickupableItem.tscn")
var enemy_scene := load("res://Nodes/Enemy.tscn")
var boss_scene := load("res://Nodes/Boss.tscn")

var spawn_pickupable_time = 5
var spawn_pickupable_timer = 0
var min_spawn_pickupableitem_radius = 120
var max_spawn_pickupableitem_radius = 400

var spawn_enemy_time = 20
var spawn_enemy_timer = 0



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
		add_child(pickupable_item)
		pickupable_item.global_position = globals.center.global_position + Vector2(spawn_radius, 0).rotated(spawn_angle)

	if spawn_enemy_timer < spawn_enemy_time:
		spawn_enemy_timer += delta
	else:
		spawn_enemy_timer = 0
		var enemy = enemy_scene.instance()
		$Center.add_child(enemy)
		
	if !$Center.has_node("Boss1"):
		var boss = boss_scene.instance()
		boss.name = "Boss1"
		boss.start_timer = 10.0
		boss.orbit_side = 1
		$Center.add_child(boss)
#		boss.get_node("Start_Timer").wait_time = 10.0
	if !$Center.has_node("Boss2"):
		var boss = boss_scene.instance()
		boss.name = "Boss2"
		boss.start_timer = 10.0
		$Center.add_child(boss)
#		boss.get_node("Start_Timer").wait_time = 10.0

var endgame: int

func _on_endgame_timer_timeout():
	var explo = preload("res://Nodes/big_explosion.tscn").instance()
	add_child(explo)
	explo.rotation=rand_range(0,2*PI)
	explo.scale*=rand_range(0.5,1.5)
	explo.global_position=Vector2(1024,1024)+Vector2(rand_range(-300,300),rand_range(-300,300))
	
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
	if endgame >= 400:
		get_tree().change_scene("res://Title.tscn")
