extends Node2D

var score = 0

signal score_changed

func add_score(s):
	score += s
	emit_signal("score_changed")

func draw_explosion(position: Vector2, radius: float, damage: float):
	radius = map.update_grid_penetrating_explosive_damage_circle(position, radius, damage, 0.3)
	
	var x := clamp(position.x - radius, 0, map.get_texture().get_width())
	var y := clamp(position.y - radius, 0, map.get_texture().get_height())
	var w := min(radius * 2, map.get_texture().get_width() - x)
	var h := min(radius * 2, map.get_texture().get_height() - y)
	
	map.update_texture(Vector2(x, y), Vector2(w, h))
	map.generate_mipmaps()


func draw_heal(position: Vector2, radius: float, heal: float):
	map.update_grid_damage_circle_hardness(position, radius, -heal, 10)
	
	var x := clamp(position.x - radius, 0, map.get_texture().get_width())
	var y := clamp(position.y - radius, 0, map.get_texture().get_height())
	var w := min(radius * 2, map.get_texture().get_width() - x)
	var h := min(radius * 2, map.get_texture().get_height() - y)
	
	map.update_texture(Vector2(x, y), Vector2(w, h))
	map.generate_mipmaps()



func draw_image(position: Vector2, brush_image, positive: int):
	map.update_grid_with_mask(position, brush_image, positive )
	
	var x := clamp(position.x - brush_image.get_width()/2, 0, map.get_texture().get_width())
	var y := clamp(position.y - brush_image.get_height()/2, 0, map.get_texture().get_height())
	var w := min(brush_image.get_width(), map.get_texture().get_width() - x)
	var h := min(brush_image.get_height(), map.get_texture().get_height() - y)
	
	map.update_texture(Vector2(x, y), Vector2(w, h))
	map.generate_mipmaps()



var center: Node2D
var map: DynamicGridMap

var gravity_scale := 98.0 *0.5
var gravity_center :Vector2
var center_of_gravity :Vector2

func kill_sound(player):
	player.get_parent().remove_child(player)
	add_child(player)
	player.connect("finished", player, "queue_free")
