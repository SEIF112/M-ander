extends RefCounted
class_name TestRandomHardness

func get_test_name() -> String:
	return "Random Hardness Tests"

func run():
	test_same_seed_same_sequence()
	test_ranges_correct()
	test_full_range_reached()
	test_different_seeds_different_sequences()

# ---------------------------------------------------------
# 1) Gleicher Seed → gleiche Folge
# ---------------------------------------------------------
func test_same_seed_same_sequence():
	var material := load("res://resources/materials/earth.tres")

	var rng1 := RandomNumberGenerator.new()
	rng1.seed = 42

	var rng2 := RandomNumberGenerator.new()
	rng2.seed = 42

	var seq1 : Array[float] = []
	var seq2 : Array[float] = []

	for i in 10:
		seq1.append(MapGenerator.roll_hardness(material, 0, 20, rng1))
		seq2.append(MapGenerator.roll_hardness(material, 0, 20, rng2))

	Helper.check(seq1 == seq2, "Same seed produces identical sequence")

# ---------------------------------------------------------
# 2) 0–20 % → 20–24, 80–100 % → 36–40
# ---------------------------------------------------------
func test_ranges_correct():
	var material := load("res://resources/materials/earth.tres")

	var rng := RandomNumberGenerator.new()
	rng.seed = 42

	var low_values : Array[float] = []
	var high_values : Array[float] = []

	for i in 1000:
		low_values.append(MapGenerator.roll_hardness(material, 0, 20, rng))
		high_values.append(MapGenerator.roll_hardness(material, 80, 100, rng))

	var low_ok = low_values.min() >= 20 and low_values.max() <= 24
	var high_ok = high_values.min() >= 36 and high_values.max() <= 40

	Helper.check(low_ok, "Earth hardness 0–20% stays between 20–24")
	Helper.check(high_ok, "Earth hardness 80–100% stays between 36–40")

# ---------------------------------------------------------
# 3) 0–100 % erreicht beide Enden (20 und 40)
# ---------------------------------------------------------
func test_full_range_reached():
	var material := load("res://resources/materials/earth.tres")

	var rng := RandomNumberGenerator.new()
	rng.seed = 42

	var values : Array[float] = []

	for i in 2000:
		values.append(MapGenerator.roll_hardness(material, 0, 100, rng))

	var has_min = values.has(20)
	var has_max = values.has(40)

	Helper.check(has_min and has_max, "Earth hardness 0–100% reaches both 20 and 40")

# ---------------------------------------------------------
# 4) Zwei verschiedene Seeds → verschiedene Folgen
# ---------------------------------------------------------
func test_different_seeds_different_sequences():
	var material := load("res://resources/materials/earth.tres")

	var rng1 := RandomNumberGenerator.new()
	rng1.seed = 42

	var rng2 := RandomNumberGenerator.new()
	rng2.seed = 1337

	var seq1 : Array[float] = []
	var seq2 : Array[float] = []

	for i in 10:
		seq1.append(MapGenerator.roll_hardness(material, 0, 20, rng1))
		seq2.append(MapGenerator.roll_hardness(material, 0, 20, rng2))

	Helper.check(seq1 != seq2, "Different seeds produce different sequences")
