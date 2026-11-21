class_name LineGraph
extends Control

var x_values := PackedFloat32Array()
var y_values := PackedFloat32Array()
var x_title := "Zeit (Jahre)"
var y_title := "Verlorene Fläche (Tiles)"


func _ready() -> void:
	resized.connect(queue_redraw)


func set_data(xs: PackedFloat32Array, ys: PackedFloat32Array) -> void:
	x_values = xs
	y_values = ys
	queue_redraw()


func _draw() -> void:
	var font := get_theme_default_font()
	var font_size := get_theme_default_font_size()
	var plot := Rect2(Vector2(64, 28), size - Vector2(84, 76))
	if plot.size.x <= 10 or plot.size.y <= 10:
		return

	draw_rect(plot, Color(0.13, 0.13, 0.13))
	draw_string(font, Vector2(plot.position.x, 18), y_title, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
	draw_string(font, Vector2(plot.position.x, size.y - 8), x_title, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)

	var max_x := 0.001
	var max_y := 1.0
	for v in x_values:
		max_x = maxf(max_x, v)
	for v in y_values:
		max_y = maxf(max_y, v)

	for i in range(5):
		var f := i / 4.0
		var py := plot.end.y - plot.size.y * f
		draw_line(Vector2(plot.position.x, py), Vector2(plot.end.x, py), Color(1, 1, 1, 0.12))
		draw_string(font, Vector2(4, py + 5), "%d" % roundi(max_y * f), HORIZONTAL_ALIGNMENT_RIGHT, 52, font_size)
		var px := plot.position.x + plot.size.x * f
		draw_string(font, Vector2(px - 20, plot.end.y + 20), "%.1f" % (max_x * f), HORIZONTAL_ALIGNMENT_CENTER, 40, font_size)

	draw_rect(plot, Color(0.6, 0.6, 0.6), false, 1.0)

	if x_values.size() < 2:
		return
	var points := PackedVector2Array()
	for i in x_values.size():
		points.append(Vector2(
			plot.position.x + plot.size.x * x_values[i] / max_x,
			plot.end.y - plot.size.y * y_values[i] / max_y))
	draw_polyline(points, Color(0.3, 0.7, 1.0), 2.0, true)
