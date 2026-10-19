class_name HexMath
extends RefCounted

#return center pixel position
static func hex_to_pixel(q: int, r: int, size: float) -> Vector2:
	var x = size * (sqrt(3.0) * q + sqrt(3.0)/2.0 * r)
	var y = size * (3.0/2.0 * r)
	var cords : Vector2 = Vector2(x,y)
	return cords 

#returns vertexes for a pointy top hexagon
static func hex_corners(center: Vector2, size: float) -> PackedVector2Array:
	var result := PackedVector2Array()
	var corners : float = 6
	for corner in corners:
		var angle = 60 * corner - 30
		var vertex = center + Vector2(
			size * cos(deg_to_rad(angle)),
			size * sin(deg_to_rad(angle))
		)
		
		result.append(vertex)
	return result
