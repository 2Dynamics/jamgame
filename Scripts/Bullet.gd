extends Node2D
class_name Bullet

var velocity := Vector2.ZERO
var dmg := 0
var dmg_radius := 0
var accel := Vector2.ZERO
var center_of_gravity := Vector2.ZERO

onready var sprite := $Sprite

func _ready():
	center_of_gravity = globals.gravity_center
#	center_of_gravity = globals.center.global_position
	pass

func _physics_process(delta):
	accel += (center_of_gravity-global_position).normalized() * globals.gravity_scale
	position += velocity * delta + (accel * delta * delta) / 2
	velocity += accel * delta - velocity * 0.002
	accel = Vector2.ZERO
	rotation = (velocity.angle())

	if collideWithMap():
		globals.draw_explosion(global_position, dmg_radius, dmg)
		destroy()
		# todo
		pass
	pass

func destroy():
	queue_free()

func _process(delta):

	pass

func collideWithMap():
	return globals.map.is_pixel_solid_v(global_position)
	pass
