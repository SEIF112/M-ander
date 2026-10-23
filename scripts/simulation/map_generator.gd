class_name MapGenerator
extends RefCounted

static func generate(gen_settings: MapGenerationSettings, sim_settings: SimulationSettings) -> MapData:
	
	var map := MapData.new()
	# 1. Seed bestimmen (falls keiner vorgegeben: zufällig wählen)
	if gen_settings.seed_value == 0:
		map.seed = randi()
	else: map.seed = gen_settings.seed_value
	
	# 2. MapData erzeugen, Größe setzen, Seed in MapData ablegen
	map.generate_empty(gen_settings.width ,gen_settings.height)
	# 3. Stufen der Reihe nach aufrufen:
	#    _generate_base_layer(...)
	_generate_base_layer(map, gen_settings.base_material)
	#    _generate_clusters(...)     (kommt später)
	#    _roll_all_resistance(...)   (kommt später)
	#    _carve_river(...)           (kommt später)
	# 4. MapData zurückgeben
	return map
	
static func _make_rng(main_seed: int, stage_name: String) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	var combined := str(main_seed) + ":" + stage_name
	rng.seed = hash(combined)
	return rng

static func _generate_base_layer(map_data: MapData, base_material: Enums.TileMaterial) -> void:
	# TODO: über alle Tiles iterieren, material setzen
	for key in map_data.tiles:
		var tile : Tile = map_data.tiles[key]
		tile.material = base_material

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
