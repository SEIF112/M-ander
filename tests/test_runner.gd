extends Node

func _ready():
	print("\n=== RUNNING TESTS ===\n")

	var tests = [
		load("res://tests/map_generator/test_random_hardness.gd").new(),
		# später weitere Tests
	]

	for t in tests:
		print("Running: ", t.get_test_name())
		t.run()

	print("\n=== ALL TESTS DONE ===\n")
