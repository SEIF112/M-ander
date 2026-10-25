extends TestBase
class_name TestPresetStore

const TEST_NAME := "__test_preset__"

func _init():
	_name = "Preset Store Tests"

func run() -> void:
	test_preset_roundtrip()
	test_missing_preset_returns_null()


# ---------------------------------------------------------
# 1) Preset speichern, laden und wiederverwenden
# ---------------------------------------------------------

func test_preset_roundtrip() -> void:
	var gen := MapGenerationSettings.new()
	gen.seed_value = 4242
	gen.base_material = Enums.TileMaterial.SAND
	gen.enabled_materials[Enums.TileMaterial.STONE] = false

	var sim := SimulationSettings.new()
	sim.min_soil_hardness = 30.0
	sim.max_soil_hardness = 60.0

	var preset := MapPreset.new()
	preset.preset_name = TEST_NAME
	preset.gen_settings = gen
	preset.sim_settings = sim

	assert_equal(
		PresetStore.save_preset(preset),
		OK,
		"Preset saves without error"
	)

	var loaded := PresetStore.load_preset(TEST_NAME)

	assert_equal(
		loaded != null,
		true,
		"Preset loads successfully"
	)

	if loaded == null:
		return

	assert_equal(
		loaded.gen_settings.seed_value,
		4242,
		"Seed survives save/load"
	)

	assert_equal(
		loaded.gen_settings.enabled_materials[Enums.TileMaterial.STONE],
		false,
		"Disabled material survives save/load"
	)

	assert_equal(
		loaded.sim_settings.max_soil_hardness,
		60.0,
		"Simulation settings survive save/load"
	)

	assert_equal(
		loaded.generator_version,
		MapPreset.GENERATOR_VERSION,
		"Generator version is stored"
	)

	var original := MapGenerator.generate(gen, sim)
	var restored := MapGenerator.generate(
		loaded.gen_settings,
		loaded.sim_settings
	)

	var identical := true

	for key: Vector2i in original.tiles:
		var a: Tile = original.tiles[key]
		var b: Tile = restored.tiles.get(key)

		if b == null:
			identical = false
			break

		if a.material != b.material:
			identical = false
			break

		if a.water_state != b.water_state:
			identical = false
			break

		if a.resistance != b.resistance:
			identical = false
			break

	assert_equal(
		identical,
		true,
		"Loaded preset regenerates identical map"
	)

	PresetStore.delete_preset(TEST_NAME)

	assert_equal(
		PresetStore.list_presets().has(TEST_NAME),
		false,
		"Deleted preset disappears from list"
	)


# ---------------------------------------------------------
# 2) Fehlendes Preset liefert null
# ---------------------------------------------------------

func test_missing_preset_returns_null() -> void:
	assert_equal(
		PresetStore.load_preset("__does_not_exist__"),
		null,
		"Missing preset returns null"
	)
