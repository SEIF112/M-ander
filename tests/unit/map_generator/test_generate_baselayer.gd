extends TestBase
class_name TestGenerateBaseLayer

func _init():
	_name = "Generate Base Layer Tests"

func run():
	test_all_tiles_are_overwritten()
	test_empty_map_does_not_crash()
	test_material_is_set_correctly()
	test_correct_tile_count()
	test_all_tiles_have_base_material()
	test_seed_behavior()
	test_rng_determinism()


# ---------------------------------------------------------
# 1) Alle Tiles werden überschrieben
# ---------------------------------------------------------
func test_all_tiles_are_overwritten():
	var map_data := MapData.new()
	map_data.tiles = {
		Vector2i(0, 0): Tile.new(),
		Vector2i(1, 0): Tile.new(),
		Vector2i(0, 1): Tile.new()
	}

	# Vorher: unterschiedliche Materialien
	map_data.tiles[Vector2i(0, 0)].material = Enums.TileMaterial.SAND
	map_data.tiles[Vector2i(1, 0)].material = Enums.TileMaterial.STONE
	map_data.tiles[Vector2i(0, 1)].material = Enums.TileMaterial.EARTH

	MapGenerator._generate_base_layer(map_data, Enums.TileMaterial.EARTH)

	var errors := []

	for key in map_data.tiles:
		if map_data.tiles[key].material != Enums.TileMaterial.EARTH:
			errors.append("Tile %s was not overwritten" % [str(key)])

	assert_equal(
		errors.size(),
		0,
        "Tiles are overwritten correctly"
	)


# ---------------------------------------------------------
# 2) Leere MapData → kein Crash
# ---------------------------------------------------------
func test_empty_map_does_not_crash():
	var map_data := MapData.new()
	map_data.tiles = {}  # leer

	MapGenerator._generate_base_layer(map_data, Enums.TileMaterial.SAND)

	assert_equal(
		map_data.tiles.size(),
		0,
        "Empty map_data does not crash"
	)


# ---------------------------------------------------------
# 3) Material wird korrekt gesetzt
# ---------------------------------------------------------
func test_material_is_set_correctly():
	var map_data := MapData.new()
	map_data.tiles = {
		Vector2i(2, 3): Tile.new()
	}

	MapGenerator._generate_base_layer(map_data, Enums.TileMaterial.EARTH)

	assert_equal(
		map_data.tiles[Vector2i(2, 3)].material,
		Enums.TileMaterial.EARTH,
        "Single tile is set correctly"
	)


# -------------------------------------------------------------------
# 4) Tile count korrekt
# -------------------------------------------------------------------
func test_correct_tile_count():
	var gen_settings := MapGenerationSettings.new()
	gen_settings.width = 8
	gen_settings.height = 6
	gen_settings.base_material = Enums.TileMaterial.SAND
	gen_settings.seed_value = 12345

	var sim_settings := SimulationSettings.new()
	var map := MapGenerator.generate(gen_settings, sim_settings)

	assert_equal(
		map.tiles.size(),
		gen_settings.width * gen_settings.height,
        "Tile count matches width * height"
	)


# -------------------------------------------------------------------
# 5) Basisschicht: Alle Tiles haben das Basismaterial
# -------------------------------------------------------------------
func test_all_tiles_have_base_material():
	var materials := [
		Enums.TileMaterial.SAND,
		Enums.TileMaterial.GRAVEL,
		Enums.TileMaterial.EARTH,
		Enums.TileMaterial.STONE
	]

	var errors := []

	for mat in materials:
		# MapData vorbereiten
		var map := MapData.new()
		map.generate_empty(5, 5)

		# Basisschicht direkt testen
		MapGenerator._generate_base_layer(map, mat)

		# Prüfen, ob ALLE Tiles korrekt gesetzt wurden
		for key in map.tiles:
			if map.tiles[key].material != mat:
				errors.append("Tile %s was not set to %s" % [str(key), str(mat)])

	assert_equal(
		errors.size(),
		0,
        "Base layer sets all tiles to the base material"
	)



# -------------------------------------------------------------------
# 6) Seed-Verhalten
# -------------------------------------------------------------------
func test_seed_behavior():
	var sim_settings := SimulationSettings.new()

	var gen_a := MapGenerationSettings.new()
	gen_a.width = 4
	gen_a.height = 4
	gen_a.base_material = Enums.TileMaterial.SAND
	gen_a.seed_value = 1234

	var gen_b := MapGenerationSettings.new()
	gen_b.width = 4
	gen_b.height = 4
	gen_b.base_material = Enums.TileMaterial.SAND
	gen_b.seed_value = 1234

	var map_a := MapGenerator.generate(gen_a, sim_settings)
	var map_b := MapGenerator.generate(gen_b, sim_settings)

	var errors := []

	if map_a.seed != map_b.seed:
		errors.append("Same seed_value produced different seeds")

	var gen_r1 := MapGenerationSettings.new()
	gen_r1.width = 4
	gen_r1.height = 4
	gen_r1.base_material = Enums.TileMaterial.SAND
	gen_r1.seed_value = 0

	var gen_r2 := MapGenerationSettings.new()
	gen_r2.width = 4
	gen_r2.height = 4
	gen_r2.base_material = Enums.TileMaterial.SAND
	gen_r2.seed_value = 0

	var map_r1 := MapGenerator.generate(gen_r1, sim_settings)
	var map_r2 := MapGenerator.generate(gen_r2, sim_settings)

	if map_r1.seed == map_r2.seed:
		errors.append("Random seed_value=0 produced identical seeds")

	assert_equal(
		errors.size(),
		0,
        "Seed behavior correct"
	)


# -------------------------------------------------------------------
# 7) RNG deterministisch
# -------------------------------------------------------------------
func test_rng_determinism():
	var seed := 777

	var rng_a1 := MapGenerator._make_rng(seed, "base")
	var rng_a2 := MapGenerator._make_rng(seed, "base")

	var seq1 := []
	var seq2 := []

	for i in range(5):
		seq1.append(rng_a1.randf())
		seq2.append(rng_a2.randf())

	var errors := []

	if seq1 != seq2:
		errors.append("Same stage_name produced different sequences")

	var rng_b := MapGenerator._make_rng(seed, "clusters")
	var seq3 := []

	for i in range(5):
		seq3.append(rng_b.randf())

	if seq1 == seq3:
		errors.append("Different stage_name produced identical sequences")

	assert_equal(
		errors.size(),
		0,
        "RNG deterministic"
	)
