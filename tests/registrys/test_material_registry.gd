extends RefCounted
class_name TestMaterialRegistry

func get_test_name() -> String:
	return "MaterialRegistry Tests"

func run():
	test_valid_key_loads_material()
	test_invalid_key_returns_null()

# ---------------------------------------------------------
# 1) Gültiger Key → MaterialData wird geladen
# ---------------------------------------------------------
func test_valid_key_loads_material():
	var registry := preload("res://core/material_regestry.gd").new()

	var material := registry.get_material_data(Enums.TileMaterial.EARTH)

	Helper.check(material is MaterialData, "Valid key loads MaterialData")

# ---------------------------------------------------------
# 2) Ungültiger Key → null + Error
# ---------------------------------------------------------
func test_invalid_key_returns_null():
	var registry := preload("res://core/material_regestry.gd").new()

	var material := registry.get_material_data(999)  # absichtlich ungültig

	Helper.check(material == null, "Invalid key returns null")
