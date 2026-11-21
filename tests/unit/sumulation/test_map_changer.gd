extends TestBase
class_name TestMapChanger

func _init():
	_name = "Map changer"

func run() -> void:
	test_can_silt()
	test_long_run()
	test_determinism()


func _set_water(map: MapData, coords: Array) -> void:
	for c: Vector2i in coords:
		map.get_tile(c.x, c.y).water_state = Enums.WaterState.RIVER_ACTIVE


func test_can_silt() -> void:
	var map := MapData.new()
	map.generate_empty(8, 6)
	# Kette (3,1) - (3,2) - (2,3) und ein einzelnes Tile (0,2), damit Zeile 2 zwei Wassertiles hat
	_set_water(map, [Vector2i(3, 1), Vector2i(3, 2), Vector2i(2, 3), Vector2i(0, 2)])
	var counts := RiverGeometry.row_counts(map)
	assert_equal(RiverGeometry.can_silt(map, map.get_tile(3, 2), counts), false, "Middle tile of a narrow river must not silt up (ring rule)")
	assert_equal(RiverGeometry.can_silt(map, map.get_tile(3, 1), counts), false, "Last water tile of a row must not silt up (row rule)")
	_set_water(map, [Vector2i(4, 1)])
	counts = RiverGeometry.row_counts(map)
	assert_equal(RiverGeometry.can_silt(map, map.get_tile(3, 1), counts), true, "Edge tile of a wide river may silt up")


func _make_changer(seed_value: int) -> MapChanger:
	var gen := MapGenerationSettings.new()
	gen.seed_value = seed_value
	var sim := SimulationSettings.new()
	var tuning := SimulationTuning.new()
	return MapChanger.new(MapGenerator.generate(gen, sim, tuning), sim, tuning)


func test_long_run() -> void:
	var changer := _make_changer(11)
	var start_water := RiverGeometry.row_counts(changer.map)
	var start_total := 0
	for c in start_water:
		start_total += c

	for i in 364 * 3:
		changer.step()

	var counts := RiverGeometry.row_counts(changer.map)
	var every_row := true
	var total := 0
	for c in counts:
		total += c
		if c < 1:
			every_row = false
	assert_equal(every_row, true, "After 3 years every row still contains water")
	assert_equal(_is_connected(changer.map), true, "After 3 years the river is still one connected strand")

	var balances_ok := true
	var vegetation_ok := true
	for tile: Tile in changer.map.tiles.values():
		if tile.water_state == Enums.WaterState.NONE and tile.bank_balance >= 0.0:
			balances_ok = false
		if tile.vegetation_density < 0.0 or tile.vegetation_density > 1.0:
			vegetation_ok = false
	assert_equal(balances_ok, true, "Land tiles always have a negative bank balance after a tick")
	assert_equal(vegetation_ok, true, "Vegetation density stays within 0..1")
	print("Water tiles: start ", start_total, ", after 3 years ", total)


func test_determinism() -> void:
	var a := _make_changer(5)
	var b := _make_changer(5)
	for i in 400:
		a.step()
		b.step()
	var diffs := 0
	for key: Vector2i in a.map.tiles:
		var ta: Tile = a.map.tiles[key]
		var tb: Tile = b.map.tiles[key]
		if ta.water_state != tb.water_state or ta.bank_balance != tb.bank_balance:
			diffs += 1
	assert_equal(diffs, 0, "Same seed gives the same simulation")


func _is_connected(map: MapData) -> bool:
	var water: Array[Tile] = []
	for tile: Tile in map.tiles.values():
		if tile.water_state == Enums.WaterState.RIVER_ACTIVE:
			water.append(tile)
	if water.is_empty():
		return false
	var visited := {Vector2i(water[0].axial_q, water[0].axial_r): true}
	var queue: Array[Tile] = [water[0]]
	while not queue.is_empty():
		var current: Tile = queue.pop_back()
		for n in map.get_neighbors(current.axial_q, current.axial_r):
			var key := Vector2i(n.axial_q, n.axial_r)
			if n.water_state == Enums.WaterState.RIVER_ACTIVE and not visited.has(key):
				visited[key] = true
				queue.append(n)
	return visited.size() == water.size()
