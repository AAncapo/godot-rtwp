extends Control

var radius:float

func _draw() -> void:
	size = Vector2.ONE * ((radius * 2) *100)
	
	draw_arc(
	size /2,           #center_position
	radius * 50,       #radius
	0,                 #start_angle
	360,               #end_angle
	100,               #point_count
	Color.WHITE_SMOKE, #color
	1.0,               #width
	true               #antialiased
	)
