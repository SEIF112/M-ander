class_name MapGenerator
extends RefCounted

static func generate(gen_settings: MapGenerationSettings, sim_settings: SimulationSettings) -> MapData:
	var map := MapData.new()
	map.seed = gen_settings.seed_value if gen_settings.seed_value != 0 else randi()
	map.generate_empty(gen_settings.width, gen_settings.height)

	_generate_base_layer(map, gen_settings.base_material)
	_generate_clusters(map, gen_settings)
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

	# Ausdehnung der echten Karte, unabhängig davon, wie generate_empty() die Zeilen versetzt
	var min_x := INF
	var max_x := -INF
	var last_row := 0
	for tile: Tile in map_data.tiles.values():
		var x := _tile_x(tile)
		min_x = minf(min_x, x)
		max_x = maxf(max_x, x)
		last_row = maxi(last_row, tile.axial_r)
	var center_x := (min_x + max_x) / 2.0
	var max_swing := maxf((max_x - min_x) / 2.0 - sqrt(3.0), 0.0)   # mind. 1 Tile Abstand zum Rand
	var swing := minf(gen_settings.river_amplitude * sqrt(3.0), max_swing)
	var wavelength := maxf(gen_settings.river_wavelength, 1.0)

	# 1. Pro Zeile Zielposition bestimmen und das nächstgelegene Tile merken
	var targets: Array[float] = []
	for row in range(last_row + 1):
		targets.append(center_x + swing * sin(TAU * row / wavelength + phase))

	var best_tiles: Array[Tile] = []
	best_tiles.resize(last_row + 1)
	var best_dists: Array[float] = []
	best_dists.resize(last_row + 1)
	best_dists.fill(INF)
	for tile: Tile in map_data.tiles.values():
		var dist := absf(_tile_x(tile) - targets[tile.axial_r])
		if dist < best_dists[tile.axial_r]:
			best_dists[tile.axial_r] = dist
			best_tiles[tile.axial_r] = tile

	# 2. Aufeinanderfolgende Zeilenpunkte per Hex-Linie verbinden -> lückenlos von oben nach unten
	for row in range(last_row + 1):
		var a: Tile = best_tiles[row]
		a.water_state = Enums.WaterState.RIVER_ACTIVE
		if row == last_row:
			break
		var b: Tile = best_tiles[row + 1]
		for pos in _hex_line(Vector2i(a.axial_q, a.axial_r), Vector2i(b.axial_q, b.axial_r)):
			var t := map_data.get_tile(pos.x, pos.y)
			if t != null:
				t.water_state = Enums.WaterState.RIVER_ACTIVE


static func _tile_x(tile: Tile) -> float:
	return HexMath.hex_to_pixel(tile.axial_q, tile.axial_r, 1.0).x


@warning_ignore("integer_division")
static func _hex_distance(a: Vector2i, b: Vector2i) -> int:
	var dq := a.x - b.x
	var dr := a.y - b.y
	return (absi(dq) + absi(dr) + absi(dq + dr)) / 2


static func _hex_line(a: Vector2i, b: Vector2i) -> Array[Vector2i]:
	var n := _hex_distance(a, b)
	var result: Array[Vector2i] = []
	for i in range(n + 1):
		var t := float(i) / maxf(n, 1.0)
		# winziger Versatz, damit das Runden an Kanten eindeutig bleibt
		result.append(_axial_round(lerpf(a.x, b.x, t) + 1e-6, lerpf(a.y, b.y, t) + 2e-6))
	return result


static func _axial_round(q: float, r: float) -> Vector2i:
	var s := -q - r
	var rq := roundf(q)
	var rr := roundf(r)
	var rs := roundf(s)
	var dq := absf(rq - q)
	var dr := absf(rr - r)
	var ds := absf(rs - s)
	if dq > dr and dq > ds:
		rq = -rr - rs
	elif dr > ds:
		rr = -rq - rs
	return Vector2i(int(rq), int(rr))
