extends Node2D
class_name Bullet

var velocity := Vector2.ZERO
var dmg := 0
var dmg_radius := 0
var accel := Vector2.ZERO
var center_of_gravity := Vector2.ZERO
var gravicy_accel_val := 98.0

# Called when the node enters the scene tree for the first time.
func _ready():
	center_of_gravity = globals.center.global_position
	pass # Replace with function body.

func _physics_process(delta):
	accel += (center_of_gravity-global_position).normalized() * gravicy_accel_val
	position += velocity * delta + (accel * delta * delta) / 2
	velocity += accel * delta
	accel = Vector2.ZERO
	rotation = (velocity.angle())

	if collideWithMap():
		globals.draw_explosion(global_position, dmg_radius, dmg)
		queue_free()
		# todo
		pass
	pass

func _process(delta):

	pass

func collideWithMap():
	return globals.map.is_pixel_solid_v(global_position)
	pass
