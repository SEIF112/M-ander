class_name MapChanger
extends RefCounted

var map: MapData
var sim: SimulationSettings   # dieselbe Instanz wie im SimulationManager, wird jeden Tick live gelesen
var tuning: SimulationTuning
var tick: int = 0
var _rng: RandomNumberGenerator


func _init(map_data: MapData, sim_settings: SimulationSettings, sim_tuning: SimulationTuning) -> void:
	map = map_data
	sim = sim_settings
	tuning = sim_tuning
	_rng = MapGenerator._make_rng(map.seed, "simulation")


func step() -> void:
	# 1. Klima (global)
	var season := ClimateModel.season(tick, tuning.ticks_per_year)
	var temperature := ClimateModel.temperature(season, sim.min_temperature, sim.max_temperature)
	var level := ClimateModel.vegetation_level(temperature, sim.min_temperature, sim.max_temperature, sim.max_vegetation)
	var groundwater := ClimateModel.groundwater_norm(sim.groundwater_table, tuning.groundwater_range)

	# 2. bis 4. Vegetation, Flussform, relevante Tiles
	_update_vegetation(level)
	var shape := RiverGeometry.analyze(map, tuning.curvature_span, tuning.k_ref)
	var water := _water_tiles()
	var banks := _bank_tiles(water)

	# 5. und 6. Erosion und Ablagerung (noch kein Zustandswechsel)
	_erode(banks, shape, temperature, groundwater)
	_deposit(water, shape)

	# 7. Wechsel anwenden
	_apply_changes(banks, water)

	# 8.
	tick += 1
	map.map_changed.emit()


func _update_vegetation(level: float) -> void:
	for tile: Tile in map.tiles.values():
		if tile.water_state != Enums.WaterState.NONE:
			continue
		var target := ClimateModel.vegetation_target(tile.max_vegetation_potential, level)
		tile.vegetation_density = ClimateModel.vegetation_step(tile.vegetation_density, target, tuning.vegetation_response)


func _water_tiles() -> Array[Tile]:
	var result: Array[Tile] = []
	for tile: Tile in map.tiles.values():
		if tile.water_state == Enums.WaterState.RIVER_ACTIVE:
			result.append(tile)
	return result


func _bank_tiles(water: Array[Tile]) -> Array[Tile]:
	var seen := {}
	var result: Array[Tile] = []
	for w in water:
		for n in map.get_neighbors(w.axial_q, w.axial_r):
			var key := Vector2i(n.axial_q, n.axial_r)
			if n.water_state == Enums.WaterState.NONE and not seen.has(key):
				seen[key] = true
				result.append(n)
	return result


func _erode(banks: Array[Tile], shape: RiverGeometry.RiverShape, temperature: float, groundwater: float) -> void:
	for tile in banks:
		var mat := MaterialRegestry.get_material_data(tile.material)
		var resistance := ErosionModel.effective_resistance(tile, mat, temperature, groundwater, tuning)
		var weight := RiverGeometry.erosion_weight(shape.side_of(tile), shape.strength_at(tile.axial_r))
		var jitter := ErosionModel.jitter_factor(_rng, tuning)
		tile.bank_balance += ErosionModel.erosion_gain(sim, tuning, resistance, weight, 1.0, jitter)


func _deposit(water: Array[Tile], shape: RiverGeometry.RiverShape) -> void:
	for tile in water:
		var best := 0.0
		for n in map.get_neighbors(tile.axial_q, tile.axial_r):
			if n.water_state == Enums.WaterState.NONE:
				best = maxf(best, RiverGeometry.deposition_weight(shape.side_of(n), shape.strength_at(n.axial_r)))
		tile.bank_balance -= ErosionModel.deposition_loss(sim, tuning, best)


func _apply_changes(banks: Array[Tile], water: Array[Tile]) -> void:
	for tile in banks:
		if ErosionModel.becomes_water(tile.bank_balance):
			ErosionModel.make_water(tile, tuning)
	var counts := RiverGeometry.row_counts(map)   # erst jetzt, damit neues Wasser mitzählt
	for tile in water:
		if ErosionModel.becomes_land(tile.bank_balance) and RiverGeometry.can_silt(map, tile, counts):
			ErosionModel.make_land(tile)
			counts[tile.axial_r] -= 1
