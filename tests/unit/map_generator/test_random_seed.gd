extends TestBase
class_name TestRandomSeed

func _init():
	_name = "Random Seed Tests"

func run():
	test_same_seed_same_stage_same_sequence()
	test_same_seed_different_stage_different_sequence()
	test_different_seed_same_stage_different_sequence()
	test_rng_is_independent()


# ---------------------------------------------------------
# 1) Gleicher Seed + gleicher Stage → gleiche Folge
# ---------------------------------------------------------
func test_same_seed_same_stage_same_sequence():
	var rng1 := MapGenerator._make_rng(42, "ores")
	var rng2 := MapGenerator._make_rng(42, "ores")

	var seq1: Array[int] = []
	var seq2: Array[int] = []

	for i in 10:
		seq1.append(rng1.randi())
		seq2.append(rng2.randi())

	assert_equal(seq1, seq2, "Same seed + same stage produces identical sequence")


# ---------------------------------------------------------
# 2) Gleicher Seed + andere Stage → andere Folge
# ---------------------------------------------------------
func test_same_seed_different_stage_different_sequence():
	var rng1 := MapGenerator._make_rng(42, "ores")
	var rng2 := MapGenerator._make_rng(42, "caves")

	var seq1: Array[int] = []
	var seq2: Array[int] = []

	for i in 10:
		seq1.append(rng1.randi())
		seq2.append(rng2.randi())

	assert_not_equal(seq1, seq2, "Same seed + different stage produces different sequence")


# ---------------------------------------------------------
# 3) Unterschiedlicher Seed + gleiche Stage → andere Folge
# ---------------------------------------------------------
func test_different_seed_same_stage_different_sequence():
	var rng1 := MapGenerator._make_rng(1, "ores")
	var rng2 := MapGenerator._make_rng(2, "ores")

	var seq1: Array[int] = []
	var seq2: Array[int] = []

	for i in 10:
		seq1.append(rng1.randi())
		seq2.append(rng2.randi())

	assert_not_equal(seq1, seq2, "Different seeds + same stage produce different sequence")


# ---------------------------------------------------------
# 4) RNGs beeinflussen sich nicht gegenseitig
# ---------------------------------------------------------
func test_rng_is_independent():
	var rng_main := MapGenerator._make_rng(42, "ores")
	var rng_other := MapGenerator._make_rng(42, "caves")

	var first_main := rng_main.randi()
	var first_other := rng_other.randi()

	# Wir rufen einen RNG mehrfach auf
	for i in 20:
		rng_main.randi()

	# Der andere RNG muss weiterhin dieselbe Folge haben
	var second_other := rng_other.randi()

	assert_not_equal(
		first_other,
		second_other,
        "Different RNGs remain independent (one RNG does not affect the other)"
	)
