extends TestBase
class_name TestCarveRiver

func _init():
	_name = "Carve River Tests"

func run():
	test_river_marks_tiles_as_water()
	test_river_reaches_first_row()
	test_river_reaches_last_row()
	test_same_seed_same_river()
	test_different_seeds_different_river()
	test_river_connects_top_to_bottom()
	test_materials_are_not_changed()


# ---------------------------------------------------------
# Helper
# ---------------------------------------------------------

func _create_map(seed: int = 42) -> MapData:
	var map := MapData.new()
	map.seed = seed
	map.generate_empty(15, 15)

	MapGenerator._generate_base_layer(
		map,
		Enums.TileMaterial.EARTH
	)

	return map


func _create_settings() -> MapGenerationSettings:
	var settings := MapGenerationSettings.new()
	settings.river_amplitude = 3.0
	settings.river_wavelength = 14.0
	return settings


func _create_tuning() -> SimulationTuning:
	return SimulationTuning.new()


func _river_snapshot(map: MapData) -> Dictionary:
	var snapshot := {}

	for key in map.tiles:
		snapshot[key] = map.tiles[key].water_state

	return snapshot


# ---------------------------------------------------------
# 1) Fluss markiert Tiles als Wasser
# ---------------------------------------------------------

func test_river_marks_tiles_as_water():
	var map := _create_map()
	var settings := _create_settings()
	var tuning := _create_tuning()

	MapGenerator._carve_river(map, settings, tuning)

	var water_tiles := 0

	for tile: Tile in map.tiles.values():
		if tile.water_state != Enums.WaterState.NONE:
			water_tiles += 1

	assert_equal(
		water_tiles > 0,
		true,
		"River marks tiles as water"
	)


# ---------------------------------------------------------
# 2) Fluss erreicht erste Zeile
# ---------------------------------------------------------

func test_river_reaches_first_row():
	var map := _create_map()
	var settings := _create_settings()
	var tuning := _create_tuning()

	MapGenerator._carve_river(map, settings, tuning)

	var found := false

	for tile: Tile in map.tiles.values():
		if tile.axial_r == 0 and tile.water_state != Enums.WaterState.NONE:
			found = true
			break

	assert_equal(
		found,
		true,
		"River reaches first row"
	)


# ---------------------------------------------------------
# 3) Fluss erreicht letzte Zeile
# ---------------------------------------------------------

func test_river_reaches_last_row():
	var map := _create_map()
	var settings := _create_settings()
	var tuning := _create_tuning()

	MapGenerator._carve_river(map, settings, tuning)

	var max_row := 0

	for tile: Tile in map.tiles.values():
		max_row = maxi(max_row, tile.axial_r)

	var found := false

	for tile: Tile in map.tiles.values():
		if tile.axial_r == max_row and tile.water_state != Enums.WaterState.NONE:
			found = true
			break

	assert_equal(
		found,
		true,
		"River reaches last row"
	)


# ---------------------------------------------------------
# 4) Gleicher Seed -> gleicher Fluss
# ---------------------------------------------------------

func test_same_seed_same_river():
	var map_a := _create_map(12345)
	var map_b := _create_map(12345)

	var settings := _create_settings()
	var tuning := _create_tuning()

	MapGenerator._carve_river(map_a, settings, tuning)
	MapGenerator._carve_river(map_b, settings, tuning)

	assert_equal(
		_river_snapshot(map_a),
		_river_snapshot(map_b),
		"Same seed creates identical river"
	)


# ---------------------------------------------------------
# 5) Verschiedene Seeds -> unterschiedlicher Fluss
# ---------------------------------------------------------

func test_different_seeds_different_river():
	var map_a := _create_map(12345)
	var map_b := _create_map(54321)

	var settings := _create_settings()
	var tuning := _create_tuning()

	MapGenerator._carve_river(map_a, settings, tuning)
	MapGenerator._carve_river(map_b, settings, tuning)

	assert_not_equal(
		_river_snapshot(map_a),
		_river_snapshot(map_b),
		"Different seeds create different rivers"
	)


# ---------------------------------------------------------
# 6) Fluss verbindet obere und untere Kartenkante
# ---------------------------------------------------------

func test_river_connects_top_to_bottom():
	var map := _create_map()
	var settings := _create_settings()
	var tuning := _create_tuning()

	MapGenerator._carve_river(map, settings, tuning)

	var open: Array[Vector2i] = []

	for tile: Tile in map.tiles.values():
		if tile.axial_r == 0 and tile.water_state != Enums.WaterState.NONE:
			open.append(Vector2i(tile.axial_q, tile.axial_r))

	var visited := {}

	while not open.is_empty():
		var current: Vector2i = open.pop_back()

		if visited.has(current):
			continue

		visited[current] = true

		for dir in MapData.AXIAL_DIRECTIONS:
			var next := current + dir
			var neighbor := map.get_tile(next.x, next.y)

			if neighbor == null:
				continue

			if neighbor.water_state != Enums.WaterState.NONE:
				open.append(next)

	var max_row := 0

	for tile: Tile in map.tiles.values():
		max_row = maxi(max_row, tile.axial_r)

	var reached_bottom := false

	for pos in visited.keys():
		if pos.y == max_row:
			reached_bottom = true
			break

	assert_equal(
		reached_bottom,
		true,
		"River forms a continuous path from top to bottom"
	)


# ---------------------------------------------------------
# 7) Materialien bleiben unverändert
# ---------------------------------------------------------

func test_materials_are_not_changed():
	var map := _create_map()
	var settings := _create_settings()
	var tuning := _create_tuning()

	var before := {}

	for key in map.tiles:
		before[key] = map.tiles[key].material

	MapGenerator._carve_river(map, settings, tuning)

	var after := {}

	for key in map.tiles:
		after[key] = map.tiles[key].material

	assert_equal(
		before,
		after,
		"River does not change tile materials"
	)
