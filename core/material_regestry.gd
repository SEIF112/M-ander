extends Node

var materials: Dictionary[Enums.TileMaterial, MaterialData] = {
	Enums.TileMaterial.SAND: preload("res://resources/materials/sand.tres"),
	Enums.TileMaterial.GRAVEL: preload("res://resources/materials/gravel.tres"),
	Enums.TileMaterial.EARTH: preload("res://resources/materials/earth.tres"),
	Enums.TileMaterial.STONE: preload("res://resources/materials/stone.tres")
}

func get_material_data(key: Enums.TileMaterial) -> MaterialData:
	if !materials.has(key):
		var available := Enums.TileMaterial.keys()
		var key_name := str(key)
		push_error("MaterialRegistry: Unknown material key '%s'. Available keys: %s" % [key_name, available])
		return null

	return materials[key]
