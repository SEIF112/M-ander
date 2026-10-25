extends TestBase
class_name TestGenerateClusters

func _init():
	_name = "Generate Cluster Tests"

func run():
	test_disabled_materials_create_no_clusters()
	test_enabled_materials_create_cluster_tiles()
	test_base_material_only_map_stays_unchanged()
	test_same_seed_same_clusters()
	test_different_seeds_different_clusters()


# ---------------------------------------------------------
# Helper
# ---------------------------------------------------------

func _create_base_map(settings: MapGenerationSettings) -> MapData:
	var map := MapData.new()
	map.seed = settings.seed_value
	map.generate_empty(settings.width, settings.height)
	MapGenerator._generate_base_layer(map, settings.base_material)
	return map


func _material_snapshot(map: MapData) -> Dictionary:
	var result := {}

	for key in map.tiles:
		result[key] = map.tiles[key].material

	return result


# ---------------------------------------------------------
# 1) Deaktivierte Materialien erzeugen keine Cluster
# ---------------------------------------------------------

func test_disabled_materials_create_no_clusters():
	var settings := MapGenerationSettings.new()

	settings.seed_value = 42
	settings.base_material = Enums.TileMaterial.EARTH

	settings.enabled_materials = {
		Enums.TileMaterial.SAND: false,
		Enums.TileMaterial.GRAVEL: false,
		Enums.TileMaterial.EARTH: true,
		Enums.TileMaterial.STONE: true,
	}

	var map := _create_base_map(settings)

	MapGenerator._generate_clusters(map, settings)

	var has_disabled_material := false

	for tile: Tile in map.tiles.values():
		if tile.material == Enums.TileMaterial.SAND:
			has_disabled_material = true

		if tile.material == Enums.TileMaterial.GRAVEL:
			has_disabled_material = true

	assert_equal(
		has_disabled_material,
		false,
		"Disabled materials create no cluster tiles"
	)


# ---------------------------------------------------------
# 2) Aktivierte Materialien erzeugen mindestens ein Tile
# ---------------------------------------------------------

func test_enabled_materials_create_cluster_tiles():
	var settings := MapGenerationSettings.new()

	settings.seed_value = 42
	settings.base_material = Enums.TileMaterial.EARTH

	settings.enabled_materials = {
		Enums.TileMaterial.SAND: false,
		Enums.TileMaterial.GRAVEL: false,
		Enums.TileMaterial.EARTH: true,
		Enums.TileMaterial.STONE: true,
	}

	var map := _create_base_map(settings)

	MapGenerator._generate_clusters(map, settings)

	var stone_count := 0

	for tile: Tile in map.tiles.values():
		if tile.material == Enums.TileMaterial.STONE:
			stone_count += 1

	assert_equal(
		stone_count > 0,
		true,
		"Enabled material creates at least one cluster tile"
	)


# ---------------------------------------------------------
# 3) Nur Basismaterial aktiviert -> Karte bleibt unverändert
# ---------------------------------------------------------

func test_base_material_only_map_stays_unchanged():
	var settings := MapGenerationSettings.new()

	settings.seed_value = 42
	settings.base_material = Enums.TileMaterial.EARTH

	settings.enabled_materials = {
		Enums.TileMaterial.SAND: false,
		Enums.TileMaterial.GRAVEL: false,
		Enums.TileMaterial.EARTH: true,
		Enums.TileMaterial.STONE: false,
	}

	var map := _create_base_map(settings)

	var before := _material_snapshot(map)

	MapGenerator._generate_clusters(map, settings)

	var after := _material_snapshot(map)

	assert_equal(
		before,
		after,
		"Cluster stage skips base material"
	)


# ---------------------------------------------------------
# 4) Gleicher Seed -> gleiche Cluster
# ---------------------------------------------------------

func test_same_seed_same_clusters():
	var settings_a := MapGenerationSettings.new()
	settings_a.seed_value = 12345

	var settings_b := MapGenerationSettings.new()
	settings_b.seed_value = 12345

	var map_a := _create_base_map(settings_a)
	var map_b := _create_base_map(settings_b)

	MapGenerator._generate_clusters(map_a, settings_a)
	MapGenerator._generate_clusters(map_b, settings_b)

	assert_equal(
		_material_snapshot(map_a),
		_material_snapshot(map_b),
		"Same seed creates identical clusters"
	)


# ---------------------------------------------------------
# 5) Andere Seeds -> andere Cluster
# ---------------------------------------------------------

func test_different_seeds_different_clusters():
	var settings_a := MapGenerationSettings.new()
	settings_a.seed_value = 12345

	var settings_b := MapGenerationSettings.new()
	settings_b.seed_value = 54321

	var map_a := _create_base_map(settings_a)
	var map_b := _create_base_map(settings_b)

	MapGenerator._generate_clusters(map_a, settings_a)
	MapGenerator._generate_clusters(map_b, settings_b)

	assert_not_equal(
		_material_snapshot(map_a),
		_material_snapshot(map_b),
		"Different seeds create different clusters"
	)
