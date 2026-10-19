class_name HexMath
extends RefCounted

static func hex_to_pixel(q: int, r: int, size: float) -> Vector2:
	var x = size * (sqrt(3.0) * q + sqrt(3.0)/2.0 * r)
	var y = size * (3.0/2.0 * r)
	var cords : Vector2 = Vector2(x,y)
	return cords
