extends TestBase
class_name TestMaterialRegistry

func _init():
	_name = "MaterialRegistry Tests"

func run():
	test_valid_key_loads_material()
	test_invalid_key_returns_null()
	test_specific_material_loaded()

# ---------------------------------------------------------
# 1) Gültiger Key → MaterialData wird geladen
# ---------------------------------------------------------
func test_valid_key_loads_material():
	var registry := preload("res://core/material_regestry.gd").new()

	var material := registry.get_material_data(Enums.TileMaterial.EARTH)

	assert_equal(material is MaterialData, true, "Valid key loads MaterialData")

# ---------------------------------------------------------
# 2) Ungültiger Key → null + Error
# ---------------------------------------------------------
func test_invalid_key_returns_null():
	var registry := preload("res://core/material_regestry.gd").new()

	var material := registry.get_material_data(999)  # absichtlich ungültig

	assert_equal(material == null, true, "Invalid key returns null")

# ---------------------------------------------------------
# 3) Spezifischer Test: SAND lädt wirklich sand.tres
# ---------------------------------------------------------
func test_specific_material_loaded():
	var registry := preload("res://core/material_regestry.gd").new()

	var material := registry.get_material_data(Enums.TileMaterial.SAND)

	var expected := preload("res://resources/materials/sand.tres")

	assert_equal(material is MaterialData, true, "SAND loads a MaterialData")
	assert_equal(material.display_name, expected.display_name, "SAND has correct display_name")
	assert_equal(material.hardness_min, expected.hardness_min, "SAND has correct hardness_min")
	assert_equal(material.hardness_max, expected.hardness_max, "SAND has correct hardness_max")
