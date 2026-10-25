extends Node2D

@export var hex_size: float = 20.0

# TODO (nach MVP): in eine eigene Resource auslagern, falls Farben einstellbar werden sollen
const WATER_COLORS := {
	Enums.WaterState.RIVER_ACTIVE: Color(0.15, 0.45, 0.85),
	Enums.WaterState.RIVER_DEAD: Color(0.35, 0.55, 0.70),
	Enums.WaterState.LAKE: Color(0.10, 0.30, 0.65),
	Enums.WaterState.FLOOD: Color(0.45, 0.65, 0.90),
}

var _map_data: MapData

func render_map(map_data: MapData) -> void:
	if _map_data != null and _map_data.map_changed.is_connected(queue_redraw):
		_map_data.map_changed.disconnect(queue_redraw)
	_map_data = map_data
	_map_data.map_changed.connect(queue_redraw)
	queue_redraw()

func _tile_color(tile: Tile) -> Color:
	if WATER_COLORS.has(tile.water_state):
		return WATER_COLORS[tile.water_state]
	return MaterialRegestry.get_material_data(tile.material).color

func _draw() -> void:
	if _map_data == null:
		return
	for tile: Tile in _map_data.tiles.values():
		var center := HexMath.hex_to_pixel(tile.axial_q, tile.axial_r, hex_size)
		var vertexes := HexMath.hex_corners(center, hex_size)
		draw_colored_polygon(vertexes, _tile_color(tile))
		draw_polyline(vertexes, Color.BEIGE, 1.0)

func fit_to_rect(area: Rect2) -> void:
	if _map_data == null or _map_data.tiles.is_empty():
		return
	var bounds := Rect2()
	var first := true
	for tile: Tile in _map_data.tiles.values():
		var c := HexMath.hex_to_pixel(tile.axial_q, tile.axial_r, 1.0)
		var tile_rect := Rect2(c - Vector2(sqrt(3.0) / 2.0, 1.0), Vector2(sqrt(3.0), 2.0))
		bounds = tile_rect if first else bounds.merge(tile_rect)
		first = false
	hex_size = minf(area.size.x / bounds.size.x, area.size.y / bounds.size.y)
	position = area.position - bounds.position * hex_size
	queue_redraw()
