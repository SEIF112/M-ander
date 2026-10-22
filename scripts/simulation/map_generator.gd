class_name MapGenerator
extends RefCounted

static func generate(gen_settings: MapGenerationSettings, sim_settings: SimulationSettings) -> MapData:
	# 1. Seed bestimmen (falls keiner vorgegeben: zufällig wählen)
	# 2. MapData erzeugen, Größe setzen, Seed in MapData ablegen
	# 3. Stufen der Reihe nach aufrufen:
	#    _generate_base_layer(...)
	#    _generate_clusters(...)     (kommt später)
	#    _roll_all_resistance(...)   (kommt später)
	#    _carve_river(...)           (kommt später)
	# 4. MapData zurückgeben
	return MapData.new()
	
static func _make_rng(main_seed: int, stage_name: String) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	var combined := str(main_seed) + ":" + stage_name
	rng.seed = hash(combined)
	return rng

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
