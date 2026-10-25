extends TestBase
class_name TestGrowCluster

func _init():
	_name = "Grow Cluster Tests"

func run():
	test_cluster_contains_start_tile()
	test_cluster_never_exceeds_target_size()
	test_cluster_material_is_applied()
	test_same_seed_same_cluster_shape()
	test_different_seeds_different_cluster_shape()
	test_cluster_is_connected()


# ---------------------------------------------------------
# Helper
# ---------------------------------------------------------

func _create_map() -> MapData:
	var map := MapData.new()
	map.generate_empty(15, 15)
	return map


func _cluster_keys(cluster: Dictionary) -> Array:
	var keys := cluster.keys()
	keys.sort()
	return keys


# ---------------------------------------------------------
# 1) Starttile gehört immer zum Cluster
# ---------------------------------------------------------

func test_cluster_contains_start_tile():
	var map := _create_map()

	var start := map.tiles[Vector2i(5, 5)]

	var rng := RandomNumberGenerator.new()
	rng.seed = 42

	var cluster := MapGenerator._grow_cluster(
		map,
		start,
		Enums.TileMaterial.STONE,
		20,
		0.5,
		rng
	)

	assert_equal(
		cluster.has(Vector2i(start.axial_q, start.axial_r)),
		true,
		"Cluster contains start tile"
	)


# ---------------------------------------------------------
# 2) Cluster überschreitet target_size niemals
# ---------------------------------------------------------

func test_cluster_never_exceeds_target_size():
	var exceeded := false

	for seed in range(20):
		var map := _create_map()

		var rng := RandomNumberGenerator.new()
		rng.seed = seed

		var start := map.tiles[Vector2i(5, 5)]
		var target_size := 25

		var cluster := MapGenerator._grow_cluster(
			map,
			start,
			Enums.TileMaterial.STONE,
			target_size,
			0.5,
			rng
		)

		if cluster.size() > target_size:
			exceeded = true
			break

	assert_equal(
		exceeded,
		false,
		"Cluster never exceeds target size"
	)


# ---------------------------------------------------------
# 3) Cluster setzt Material korrekt
# ---------------------------------------------------------

func test_cluster_material_is_applied():
	var map := _create_map()

	var rng := RandomNumberGenerator.new()
	rng.seed = 42

	var cluster := MapGenerator._grow_cluster(
		map,
		map.tiles[Vector2i(5, 5)],
		Enums.TileMaterial.STONE,
		20,
		0.5,
		rng
	)

	var all_correct := true

	for tile: Tile in cluster.values():
		if tile.material != Enums.TileMaterial.STONE:
			all_correct = false
			break

	assert_equal(
		all_correct,
		true,
		"Cluster material is applied to all cluster tiles"
	)


# ---------------------------------------------------------
# 4) Gleicher Seed -> gleiche Clusterform
# ---------------------------------------------------------

func test_same_seed_same_cluster_shape():
	var map_a := _create_map()
	var map_b := _create_map()

	var rng_a := RandomNumberGenerator.new()
	rng_a.seed = 12345

	var rng_b := RandomNumberGenerator.new()
	rng_b.seed = 12345

	var cluster_a := MapGenerator._grow_cluster(
		map_a,
		map_a.tiles[Vector2i(5, 5)],
		Enums.TileMaterial.STONE,
		20,
		0.5,
		rng_a
	)

	var cluster_b := MapGenerator._grow_cluster(
		map_b,
		map_b.tiles[Vector2i(5, 5)],
		Enums.TileMaterial.STONE,
		20,
		0.5,
		rng_b
	)

	assert_equal(
		_cluster_keys(cluster_a),
		_cluster_keys(cluster_b),
		"Same seed creates identical cluster shape"
	)


# ---------------------------------------------------------
# 5) Andere Seeds -> andere Clusterform
# ---------------------------------------------------------

func test_different_seeds_different_cluster_shape():
	var map_a := _create_map()
	var map_b := _create_map()

	var rng_a := RandomNumberGenerator.new()
	rng_a.seed = 12345

	var rng_b := RandomNumberGenerator.new()
	rng_b.seed = 54321

	var cluster_a := MapGenerator._grow_cluster(
		map_a,
		map_a.tiles[Vector2i(5, 5)],
		Enums.TileMaterial.STONE,
		20,
		0.5,
		rng_a
	)

	var cluster_b := MapGenerator._grow_cluster(
		map_b,
		map_b.tiles[Vector2i(5, 5)],
		Enums.TileMaterial.STONE,
		20,
		0.5,
		rng_b
	)

	assert_not_equal(
		_cluster_keys(cluster_a),
		_cluster_keys(cluster_b),
		"Different seeds create different cluster shapes"
	)


# ---------------------------------------------------------
# 6) Cluster ist zusammenhängend
# ---------------------------------------------------------

func test_cluster_is_connected():
	var map := _create_map()

	var rng := RandomNumberGenerator.new()
	rng.seed = 42

	var cluster := MapGenerator._grow_cluster(
		map,
		map.tiles[Vector2i(5, 5)],
		Enums.TileMaterial.STONE,
		30,
		0.5,
		rng
	)

	var cluster_keys := cluster.keys()

	if cluster_keys.is_empty():
		assert_equal(false, true, "Cluster should not be empty")
		return

	var open := [cluster_keys[0]]
	var visited := {}

	while not open.is_empty():
		var current: Vector2i = open.pop_back()

		if visited.has(current):
			continue

		visited[current] = true

		for dir in MapData.AXIAL_DIRECTIONS:
			var neighbor := current + dir

			if cluster.has(neighbor) and not visited.has(neighbor):
				open.append(neighbor)

	assert_equal(
		visited.size(),
		cluster.size(),
		"Cluster forms a connected component"
	)
