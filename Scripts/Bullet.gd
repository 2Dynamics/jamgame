extends Node2D
class_name Bullet

export var dmg := 0
export var dmg_radius := 0
export var velocity_damping := 0.002
export var gravity_scale = 1.0

var shooter_id = -1 setget set_shooter_id, get_shooter_id
var velocity := Vector2.ZERO

func set_shooter_id(id):
	shooter_id=id
	if shooter_id < 0 or shooter_id>3:
		modulate=Color(1,1,0)

func get_shooter_id():
	return shooter_id
func _enter_tree():
	set_meta("bullet", true)

func _ready():
	if !has_node("AudioStreamPlayer"):
		add_child(preload("res://Nodes/fire_sound_default.tscn").instance())
	connect("tree_exiting", globals, "kill_sound", [$AudioStreamPlayer])

func _physics_process(delta):
	var grav = global_position.direction_to(globals.center.global_position)
	velocity += grav * globals.gravity_scale * gravity_scale * delta
	velocity -= velocity * velocity_damping
	
	position += velocity * delta
	rotation = velocity.angle()

	if collideWithMap():
		on_map_hit()
		
	check_screen_borders()

func collideWithMap() -> bool:
	return globals.map.is_pixel_solid_v(global_position)
	
func check_screen_borders():pass
func on_hit(): pass
func on_map_hit():
	on_hit()

func _on_Bullet_area_entered(area):
	if area is Player:
		if shooter_id < 0 or shooter_id>3:
			area.setStun()
			on_hit()
	elif area.is_in_group("enemies"):
		if shooter_id != area.eneny_id:
			area.damage(dmg)
			on_hit()
	elif area.has_meta("bullet"):
		if shooter_id == -1 or shooter_id == load("res://Scripts/Enemy.gd").eneny_id:
			if shooter_id != area.shooter_id:
				on_hit()
				area.on_hit()
