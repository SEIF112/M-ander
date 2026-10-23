extends TestBase
class_name TestCordinateConsistency

func _init():
	_name = "Testing for consistency errors in coordinates (Key = q % r)"

func run() -> void:
	test_hex_key_consistency()
	test_hex_neighbor_distance()

	# ---------------------------------------------------------
# 1) Key gleicht Kordinaten
# ---------------------------------------------------------
func test_hex_key_consistency():
	var map := MapData.new()
	map.generate_empty(10, 10)

	var errors := []

	for key: Vector2i in map.tiles:
		var t: Tile = map.tiles[key]
		var expected_key := Vector2i(t.axial_q, t.axial_r)

		if key != expected_key:
			errors.append(
				"Key mismatch: key=%s but tile=(%s,%s)" %
				[str(key), str(t.axial_q), str(t.axial_r)]
			)

	assert_equal(
		errors.size(),
		0,
        "Tile keys match axial coordinates"
	)

# ---------------------------------------------------------
# 2) Nachbarn werden richtig bestimmt
# ---------------------------------------------------------
func test_hex_neighbor_distance():
	var map := MapData.new()
	map.generate_empty(10, 10)

	var errors := []

	for key: Vector2i in map.tiles:
		var t: Tile = map.tiles[key]
		var p := HexMath.hex_to_pixel(t.axial_q, t.axial_r, 1.0)

		for n in map.get_neighbors(t.axial_q, t.axial_r):
			var np := HexMath.hex_to_pixel(n.axial_q, n.axial_r, 1.0)
			var d := p.distance_to(np)

			if absf(d - sqrt(3.0)) > 0.001:
				errors.append(
					"Neighbor distance incorrect: %s <-> %s = %s (expected sqrt(3))" %
					[str(key), str(Vector2i(n.axial_q, n.axial_r)), str(d)]
				)

	assert_equal(
		errors.size(),
		0,
        "All neighbors are exactly one tile width apart"
	)
