extends TestBase
class_name TestMapGenerationPipeline

func _init():
	_name = "Map Generation Pipeline Tests"

func run():
	test_generate_creates_correct_tile_count()
	test_generate_applies_clusters()
	test_generate_rolls_resistance()
	test_generate_creates_river()
	test_same_seed_creates_identical_map()
	test_different_seeds_create_different_maps()


# ---------------------------------------------------------
# Helper
# ---------------------------------------------------------

func _create_generation_settings(seed: int) -> MapGenerationSettings:
	var settings := MapGenerationSettings.new()

	settings.width = 15
	settings.height = 15

	settings.seed_value = seed
	settings.base_material = Enums.TileMaterial.EARTH

	settings.enabled_materials = {
		Enums.TileMaterial.SAND: true,
		Enums.TileMaterial.GRAVEL: true,
		Enums.TileMaterial.EARTH: true,
		Enums.TileMaterial.STONE: true,
	}

	return settings


func _create_simulation_settings() -> SimulationSettings:
	var settings := SimulationSettings.new()

	settings.min_soil_hardness = 0
	settings.max_soil_hardness = 100

	return settings


func _map_snapshot(map: MapData) -> Dictionary:
	var snapshot := {}

	for key in map.tiles:
		var tile: Tile = map.tiles[key]

		snapshot[key] = {
			"material": tile.material,
			"water_state": tile.water_state,
			"resistance": tile.resistance
		}

	return snapshot


# ---------------------------------------------------------
# 1) Richtige Tileanzahl
# ---------------------------------------------------------

func test_generate_creates_correct_tile_count():
	var map := MapGenerator.generate(
		_create_generation_settings(12345),
		_create_simulation_settings()
	)

	assert_equal(
		map.tiles.size(),
		225,
		"Pipeline creates width * height tiles"
	)


# ---------------------------------------------------------
# 2) Cluster werden angewendet
# ---------------------------------------------------------

func test_generate_applies_clusters():
	var map := MapGenerator.generate(
		_create_generation_settings(12345),
		_create_simulation_settings()
	)

	var non_base_tiles := 0

	for tile: Tile in map.tiles.values():
		if tile.material != Enums.TileMaterial.EARTH:
			non_base_tiles += 1

	assert_equal(
		non_base_tiles > 0,
		true,
		"Pipeline creates cluster materials"
	)


# ---------------------------------------------------------
# 3) Widerstände werden gewürfelt
# ---------------------------------------------------------

func test_generate_rolls_resistance():
	var map := MapGenerator.generate(
		_create_generation_settings(12345),
		_create_simulation_settings()
	)

	var resistance_found := false

	for tile: Tile in map.tiles.values():
		if tile.resistance > 0:
			resistance_found = true
			break

	assert_equal(
		resistance_found,
		true,
		"Pipeline generates resistance values"
	)


# ---------------------------------------------------------
# 4) Fluss wird erzeugt
# ---------------------------------------------------------

func test_generate_creates_river():
	var map := MapGenerator.generate(
		_create_generation_settings(12345),
		_create_simulation_settings()
	)

	var river_tiles := 0

	for tile: Tile in map.tiles.values():
		if tile.water_state == Enums.WaterState.RIVER_ACTIVE:
			river_tiles += 1

	assert_equal(
		river_tiles > 0,
		true,
		"Pipeline creates river tiles"
	)


# ---------------------------------------------------------
# 5) Gleicher Seed -> identische Karte
# ---------------------------------------------------------

func test_same_seed_creates_identical_map():
	var map_a := MapGenerator.generate(
		_create_generation_settings(12345),
		_create_simulation_settings()
	)

	var map_b := MapGenerator.generate(
		_create_generation_settings(12345),
		_create_simulation_settings()
	)

	assert_equal(
		_map_snapshot(map_a),
		_map_snapshot(map_b),
		"Same seed creates identical map"
	)


# ---------------------------------------------------------
# 6) Unterschiedliche Seeds -> andere Karte
# ---------------------------------------------------------

func test_different_seeds_create_different_maps():
	var map_a := MapGenerator.generate(
		_create_generation_settings(12345),
		_create_simulation_settings()
	)

	var map_b := MapGenerator.generate(
		_create_generation_settings(54321),
		_create_simulation_settings()
	)

	assert_not_equal(
		_map_snapshot(map_a),
		_map_snapshot(map_b),
		"Different seeds create different maps"
	)
