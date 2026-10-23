class_name MapGenerator
extends RefCounted

static func generate(gen_settings: MapGenerationSettings, sim_settings: SimulationSettings) -> MapData:
	var map := MapData.new()
	map.seed = gen_settings.seed_value if gen_settings.seed_value != 0 else randi()
	map.generate_empty(gen_settings.width, gen_settings.height)

	_generate_base_layer(map, gen_settings.base_material)
	#_generate_clusters(map, gen_settings)
	_roll_all_resistance(map, sim_settings)
	_carve_river(map, gen_settings)
	return map


static func _make_rng(main_seed: int, stage_name: String) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(str(main_seed) + ":" + stage_name)
	return rng


# ---------- Stufe 1: Basisschicht ----------

static func _generate_base_layer(map_data: MapData, base_material: Enums.TileMaterial) -> void:
	for key in map_data.tiles:
		var tile: Tile = map_data.tiles[key]
		tile.material = base_material


# ---------- Stufe 2: Cluster ----------

static func _generate_clusters(map_data: MapData, gen_settings: MapGenerationSettings) -> void:
	for material in Enums.TileMaterial.values():
		if material == gen_settings.base_material:
			continue
		if not gen_settings.enabled_materials.get(material, false):
			continue

		# Eigener Generator pro Material: Abwählen eines Materials ändert die anderen nicht
		var rng := _make_rng(map_data.seed, "clusters_" + Enums.TileMaterial.keys()[material])
		var cluster_count := rng.randi_range(1, gen_settings.max_cluster_count)

		for i in cluster_count:
			var share := rng.randf_range(gen_settings.cluster_min_share, gen_settings.cluster_max_share)
			var target_size := clampi(int(map_data.tiles.size() * share), 1, map_data.tiles.size())
			var start := _random_tile(map_data, rng)
			_grow_cluster(map_data, start, material, target_size, gen_settings.cluster_grow_chance, rng)


static func _random_tile(map_data: MapData, rng: RandomNumberGenerator) -> Tile:
	var keys := map_data.tiles.keys()
	var key: Vector2i = keys[rng.randi_range(0, keys.size() - 1)]
	return map_data.tiles[key]


static func _key(tile: Tile) -> Vector2i:
	return Vector2i(tile.axial_q, tile.axial_r)


## Läufer-Verfahren: setzt Nachbarn, springt auf einen davon, macht dort weiter.
## Gibt die Menge der Tiles dieses Clusters zurück (Key: Vector2i).
static func _grow_cluster(map_data: MapData, start: Tile, material: Enums.TileMaterial,
		target_size: int, grow_chance: float, rng: RandomNumberGenerator) -> Dictionary:
	var cluster := {}
	var walker: Tile = start
	start.material = material
	cluster[_key(start)] = start

	var steps := 0
	var max_steps := target_size * 10   # Schrittgrenze: verhindert Endlosschleifen

	while cluster.size() < target_size and steps < max_steps:
		steps += 1
		var neighbors := map_data.get_neighbors(walker.axial_q, walker.axial_r)
		if neighbors.is_empty():
			break

		# Startrichtung zufällig drehen, sonst werden frühe Richtungen bevorzugt
		var count := neighbors.size()
		var offset := rng.randi_range(0, count - 1)
		for i in count:
			if cluster.size() >= target_size:
				break
			var neighbor: Tile = neighbors[(i + offset) % count]
			if cluster.has(_key(neighbor)):
				continue
			if rng.randf() < grow_chance:
				neighbor.material = material   # überschreiben ist erlaubt
				cluster[_key(neighbor)] = neighbor

		# Läufer auf ein Cluster-Tile in der Nähe setzen, sonst auf ein beliebiges
		var candidates: Array[Tile] = []
		for neighbor in neighbors:
			if cluster.has(_key(neighbor)):
				candidates.append(neighbor)
		if candidates.is_empty():
			walker = cluster.values()[rng.randi_range(0, cluster.size() - 1)]
		else:
			walker = candidates[rng.randi_range(0, candidates.size() - 1)]

	return cluster


# ---------- Stufe 3: Widerstand würfeln ----------

static func _roll_all_resistance(map_data: MapData, sim_settings: SimulationSettings) -> void:
	var rng := _make_rng(map_data.seed, "resistance")
	for key in map_data.tiles:
		var tile: Tile = map_data.tiles[key]
		var mat := MaterialRegestry.get_material_data(tile.material)
		tile.resistance = roll_hardness(mat, sim_settings.min_soil_hardness,
				sim_settings.max_soil_hardness, rng)


static func roll_hardness(material: MaterialData, user_min: float, user_max: float, rng: RandomNumberGenerator) -> float:
	var span := material.hardness_max - material.hardness_min
	var percent := rng.randf_range(user_min, user_max) / 100.0
	return round(material.hardness_min + span * percent)


# ---------- Stufe 4: Fluss einschneiden ----------

static func _carve_river(map_data: MapData, gen_settings: MapGenerationSettings) -> void:
	var rng := _make_rng(map_data.seed, "river")
	var phase := rng.randf_range(0.0, TAU)
	var max_x := sqrt(3.0) * (map_data.width - 0.5)
	var center_x := max_x / 2.0

	# Letzte Zeile aus den echten Tiles bestimmen, nicht aus map_data.height
	var last_row := 0
	for key: Vector2i in map_data.tiles:
		last_row = maxi(last_row, key.y)
	print("River: rows=", last_row + 1, " map_data.height=", map_data.height)

	# Startpunkt: das Tile in Zeile 0, dessen x-Position dem Ziel am nächsten liegt
	var target := _river_target_x(0, center_x, max_x, gen_settings, phase)
	var current: Tile = null
	var best_dist := INF
	for key: Vector2i in map_data.tiles:
		if key.y != 0:
			continue
		var candidate: Tile = map_data.tiles[key]
		var dist := absf(_tile_x(candidate) - target)
		if dist < best_dist:
			best_dist = dist
			current = candidate
	current.water_state = Enums.WaterState.RIVER_ACTIVE

	for row in range(1, last_row + 1):
		target = _river_target_x(row, center_x, max_x, gen_settings, phase)

		# Schritt nach unten: die Nachbarn der nächsten Zeile, der näher am Ziel gewinnt
		var below: Array[Tile] = []
		for n in map_data.get_neighbors(current.axial_q, current.axial_r):
			if n.axial_r == current.axial_r + 1:
				below.append(n)
		if below.is_empty():
			push_warning("River ended early in row %d (q=%d)" % [current.axial_r, current.axial_q])
			return
		current = below[0]
		for n in below:
			if absf(_tile_x(n) - target) < absf(_tile_x(current) - target):
				current = n
		current.water_state = Enums.WaterState.RIVER_ACTIVE

		# Seitwärts laufen, solange das Ziel dadurch näher rückt (macht die Mäanderbögen)
		for i in map_data.width:
			var best: Tile = current
			var best_d := absf(_tile_x(current) - target)
			for side in [-1, 1]:
				var neighbor := map_data.get_tile(current.axial_q + side, current.axial_r)
				if neighbor == null:
					continue
				var d := absf(_tile_x(neighbor) - target)
				if d < best_d - 0.001:
					best = neighbor
					best_d = d
			if best == current:
				break
			current = best
			current.water_state = Enums.WaterState.RIVER_ACTIVE


static func _tile_x(tile: Tile) -> float:
	return HexMath.hex_to_pixel(tile.axial_q, tile.axial_r, 1.0).x


static func _river_target_x(row: int, center_x: float, max_x: float,
		gen_settings: MapGenerationSettings, phase: float) -> float:
	var swing := gen_settings.river_amplitude * sqrt(3.0) \
			* sin(TAU * row / gen_settings.river_wavelength + phase)
	return clampf(center_x + swing, 0.0, max_x)
