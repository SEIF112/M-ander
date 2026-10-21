class_name MapGenerator
extends Node

static func roll_hardness(material: MaterialData, user_min: float, user_max: float, rng: RandomNumberGenerator) -> float:
	var tile_range: float
	var min_range: float
	var max_range :float
	
	tile_range = material.hardness_max - material.hardness_min
	min_range = user_min * (tile_range / 100)
	max_range = user_max * (tile_range /100)
	
	var output: float
	output = rng.randf_range(min_range, max_range) + material.hardness_min
	output = round(output) 
	return output
