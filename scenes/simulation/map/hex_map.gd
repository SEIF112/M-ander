extends Node2D

@export var hex_size : float = 20.0

var _map_data : MapData

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func render_map(map_data: MapData) -> void:
	_map_data = map_data
	queue_redraw()
	
func _draw() -> void:
	if _map_data == null:
		return
	for tile :Tile in _map_data.tiles.values():
		var center = HexMath.hex_to_pixel(tile.axial_q, tile.axial_r, hex_size)
		var vertexes = HexMath.hex_corners(center,hex_size)
		draw_colored_polygon(vertexes, MaterialRegestry.get_material_data(tile.material).color)
		draw_polyline(vertexes, Color.BEIGE, 1.0)
