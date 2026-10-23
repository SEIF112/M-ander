class_name MapData
extends Resource

signal map_changed

@export var width: int = 10
@export var height: int = 10
@export var seed: int

var tiles: Dictionary[Vector2i, Tile] = {}

const AXIAL_DIRECTIONS: Array[Vector2i] = [
	Vector2i(1, 0),
	Vector2i(1, -1),
	Vector2i(0, -1),
	Vector2i(-1, 0),
	Vector2i(-1, 1),
	Vector2i(0, 1),
]

func get_neighbors(q: int, r: int) -> Array[Tile]:
	var neighbors: Array[Tile] = []
	for direction in AXIAL_DIRECTIONS:
		var neighbor_q := q + direction.x
		var neighbor_r := r + direction.y
		var neighbor_tile := get_tile(neighbor_q, neighbor_r)
		if neighbor_tile != null:
			neighbors.append(neighbor_tile)
	return neighbors
	
func get_tile(q: int, r:int) -> Tile:
	var tile: Tile = tiles.get(Vector2i(q, r), null)
	return tile

@warning_ignore("integer_division")
func generate_empty(local_width: int, local_height: int) -> void:
	width = local_width
	height = local_height
	tiles.clear()
	for r in range(local_height):
		var q_offset := r / 2
		for q in range(-q_offset, local_width - q_offset):
			var tile := Tile.new()
			tile.axial_q = q
			tile.axial_r = r
			tiles[Vector2i(q, r)] = tile
